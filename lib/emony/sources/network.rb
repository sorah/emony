require 'thread'
require 'socket'
require 'yajl'
require 'json'
require 'msgpack'
require 'emony/sources/base'

module Emony
  module Sources
    class Network < Base
      DEFAULT_PORT = 37866

      def initialize(*)
        super
        @options[:format] = @options[:format].to_sym if @options[:format]
        @options[:protocol] = [*@options[:protocol]].map(&:to_sym) if @options[:protocol]

        @tcp_server, @udp_server = nil, nil

        @lock = Mutex.new
      end

      def host
        @options[:host] || Socket::INADDR_ANY
      end

      def port
        @options[:port] || DEFAULT_PORT
      end

      def protocol
        @options[:protocol] || %i(tcp udp)
      end

      def start
        @lock.synchronize do
          return if running?

          if protocol.include?(:tcp)
            @tcp_server = TcpServer.new(host, port)
            @tcp_server.on_message = method(:process_message)
            @tcp_server.start
          end

          if protocol.include?(:udp)
            @udp_server = UdpServer.new(host, port)
            @udp_server.on_message = method(:process_message)
            @udp_server.start
          end
        end
      end

      def stop
        @lock.synchronize do
          if @tcp_server
            @tcp_server.stop
            @tcp_server = nil
          end
          if @udp_server
            @udp_server.stop
            @udp_server = nil
          end
        end
      end

      def running?
        !!(@tcp_server || @udp_server)
      end

      private

      def process_message(client, message)
        # TODO: hostname key
        case
        when message['data'] && message['tag']
          create_record message['tag'], message['data']
        end

        id = message.kind_of?(Hash) && message['id']
        client.send(ack: {id: id})
      end

      class ServerBase
        def initialize
          @thread, @stop = nil, nil, nil
          @on_message = proc {}
        end

        attr_accessor :on_message

        def start
          return if running?
          setup
          stopr, @stop = IO.pipe
          @thread = Thread.new(stopr, &method(:thread))
        end

        def stop
          return unless running?
          @stop.syswrite '1'
          @stop.close
          @thread.join(5)
          teardown
          @thread, @stop = nil, nil
        end

        def running?
          @thread && @thread.alive?
        end

        private

        def thread(stop)
          main_loop(stop)
        rescue Exception => e
          $stderr.puts "#{self.inspect} thread encountered an error: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
          sleep 1
          retry
        end

        def setup
          raise NotImplementedError
        end

        def teardown
          raise NotImplementedError
        end

        def main_loop(stop)
          raise NotImplementedError
        end
      end

      class TcpServer < ServerBase
        def initialize(host, port)
          super()
          @host, @port = host, port
        end

        private

        def setup
          @server = TCPServer.new(@host, @port)
          @clients = {}
        end

        def teardown
          @server.close
          @clients.each do |cli|
            cli.sock.close
          end
          @server, @clients = nil, nil
        end

        def main_loop(stop)
          loop do
            close = false
            rs, _, _ = IO.select(@clients.keys + [@server, stop])

            rs.each do |io|
              if io == @server
                accept_client
                next
              end

              if io == stop
                close = true
                stop.close
                next
              end

              client = @clients[io]
              process_client(client)
            end

            break if close
          end
        end

        def accept_client
          loop do
            sock = @server.accept_nonblock
            @clients[sock] = Client.new(sock, on_message)
          end
        rescue IO::WaitReadable
          return
        end

        def process_client(client)
          client.process!
          if client.sock.closed?
            @clients.delete client.sock
          end
        end

        class Client
          def initialize(sock, on_message)
            @sock = sock
            @on_message = on_message
            @format = nil
          end

          def send(data)
            case format
            when :json
              Yajl::Encoder.encode(data, sock)
            when :msgpack
              sock.write data.to_msgpack
            when nil
              raise '[BUG] no format determined'
            end
          end

          def process!
            if sock.eof? || sock.closed?
              sock.close unless sock.closed?
              return
            end

            buf = sock.read_nonblock(1024)

            if format.nil?
              self.format = buf[0] == '{' ? :json : :msgpack

              @parser = case format
                        when :json
                          Yajl::Parser.new.tap { |pa|
                            pa.on_parse_complete = method(:process_message)
                          }
                        when :msgpack
                          MessagePack::Unpacker.new
                        end

            end

            feed_data(buf)
          end

          def feed_data(data)
            case format
            when :json
              feed_data_json data
            when :msgpack
              feed_data_msgpack data
            end
          end

          def feed_data_json(data)
            @parser << data
          end

          def feed_data_msgpack(data)
            @parser.feed_each(data, &method(:process_message))
          end

          def process_message(data)
            @on_message.call self, data
          end

          attr_accessor :format, :sock
        end
      end

      class UdpServer < ServerBase
        def initialize(host, port)
          super()
          @host, @port = host, port
        end

        def setup
          @server = UDPSocket.new
          @server.bind @host, @port
        end

        def teardown
          @server.close
          @server = nil
        end

        def main_loop(stop)
          loop do
            rs, _, _ = IO.select([@server, stop])
            close = false
            rs.each do |io|
              if io == stop
                close = true
                next
              end

              data, addrinfo = io.recvfrom(1500)
              process_data data, addrinfo
            end
            break if close
          end
        end

        def process_data(data, addrinfo)
          format = data[0] == '{' ? :json : :msgpack

          message = case format
                    when :json
                      Yajl::Parser.parse(data)
                    when :msgpack
                      MessagePack.unpack(data)
                    end

          on_message.call Client.new(format, addrinfo, @server), message
        end

        class Client
          def initialize(format, addrinfo, sock)
            @format, @addrinfo, @sock = format, addrinfo, sock
          end

          def send(data)
            message = case @format
            when :json
              data.to_json
            when :msgpack
              data.to_msgpack
            end
            @sock.send message, 0, @addrinfo[3], @addrinfo[1]
          end
        end
      end
    end
  end
end
