require 'emony/sources/base'

require 'thread'

require 'json'
require 'emony/utils/ltsv_parser'

module Emony
  module Sources
    class Tail < Base
      def initialize(*)
        super

        @lock = Mutex.new

        @options[:format] ||= :raw

        @thread = nil
        @stop = nil

        unless @options[:tag]
          raise ArgumentError, "tag is required for any Tail source"
        end

        unless @options[:path]
          raise ArgumentError, "path is required for any Tail source"
        end
      end

      def tag
        @options[:tag]
      end

      def path
        @options[:path]
      end

      def line_processor
        @line_processor ||= begin
          klass = case @options[:format]
          when :raw
            LineProcessors::Raw
          when :ltsv
            LineProcessors::Ltsv
          when :json
            LineProcessors::Json
          else
            raise ArgumentError, "Unknown format: #{@options[:format].inspect}"
          end

          klass.new(method(:process_message), @options[:format_options] || {})
        end
      end

      def running?
        @thread && @thread.alive?
      end

      def start
        @lock.synchronize do 
          return if running?

          stopr, @stop = IO.pipe
          @thread = Thread.new(stopr, &method(:thread))
        end
      end

      def stop
        @lock.synchronize do
          return unless running?

          @stop.syswrite '1'
          @stop.close

          @thread, @stop = nil, nil
        end
      end

      def thread(stopr)
        main_loop(stopr)
      rescue Exception => e
        $stderr.puts "#{self.inspect} thread encountered an error: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
        sleep 1
        retry
      ensure
        stopr.close
      end

      def main_loop(stopr)
        tail_io = IO.popen([*%w(tail -F -n0), path], 'r')
        ios = [stopr, tail_io]
        buf = ""

        loop do
          close = false
          rs, _, _ = IO.select(ios)

          rs.each do |io|
            if io == stopr
              close = true
              next
            end

            begin
              loop do
                buf << io.read_nonblock(2048)
              end
            rescue IO::WaitReadable
            end
          end

          buf = process_buffer(buf)

          break if close
        end

      ensure
        if tail_io
          Process.kill :INT, tail_io.pid
          tail_io.close
        end
      end

      def process_buffer(buf)
        lines = buf.split(/\r?\n/)
        case
        when lines.size > 1
          buf = lines.pop
          lines.each do |line|
            line_processor.process line
          end
        when /\r?\n\z/ === buf
          line_processor.process lines[0]
          buf = ""
        end

        buf
      end

      def process_message(message)
        return unless running?
        create_record tag, message
      end

      module LineProcessors
        class Base
          def initialize(on_message, options = {})
            @options = options
            @on_message = on_message
          end

          def feed(message)
            @on_message.call message
          end
        end

        class Raw < Base
          def process(line)
            feed(message_key => line.chomp)
          end

          private
          
          def message_key
            @options[:key] || 'message'.freeze
          end
        end

        class Ltsv < Base
          def process(line)
            feed Utils::LtsvParser.parse(line)
          end
        end

        class Json < Base
          def process(line)
            msg = JSON.parse(line.chomp)
            feed msg
          rescue JSON::ParserError
            # TODO: warn parsererror
          end
        end
      end
    end
  end
end
