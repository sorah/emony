require 'emony/outputs/base'
require 'msgpack'
require 'socket'

module Emony
  module Outputs
    class Forward < Base
      DEFAULT_PORT = 37866

      def initialize(*)
        super
        raise ArgumentError, "host must be specified" unless @options[:host]
        @host, @port = @options[:host].to_s, (@options[:port] || DEFAULT_PORT).to_i
        @tcp_only = @options.key?(:tcp_only) ? !!@options[:tcp_only] : false
        @tcp_threshold ||= @options[:tcp_threshold] || 1100

        @tcp_socket, @udp_socket = nil, nil
      end

      def teardown
        if @tcp_socket
          @tcp_socket.close
        end

        if @udp_socket
          @udp_socket.close
        end
      end

      def send(window)
        return unless window.label.primary?
        msg = {window: window.to_a}.to_msgpack

        if msg.bytesize > @tcp_threshold
          send_tcp msg
        else
          send_udp msg
        end
      end

      def send_tcp(msg)
        @tcp_socket ||= TCPSocket.open(@host, @port)
        p msg
        @tcp_socket.write msg

        #unless @tcp_only # don't keepalive when UDP enabled
        #  @tcp_socket.close
        #  @tcp_socket = nil
        #end
      end

      def send_udp(msg)
        @udp_socket ||= UDPSocket.new
        @udp_socket.send msg, 0, @host, @port
      end
    end
  end
end
