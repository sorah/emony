require 'thread'

module Emony
  module Utils
    module OperationThreadable
      # TODO: test
      class AlreadyRunning < StandardError; end
      class NotStopping < StandardError; end

      def init_operation_threading
        @stop = nil
        @queue = Queue.new
        @thread = nil
      end

      def running?
        !!@thread
      end

      def stopping?
        running? && !!@stop
      end

      def start
        @lock.synchronize do
          raise AlreadyRunning if @thread
          setup
          @stop = nil
          @thread = Thread.new(&method(:main_loop))
        end
      end

      def stop
        @lock.synchronize do
          return unless @thread
          @queue << :stop
          @stop = :stop
        end

        @thread.join

        @lock.synchronize do
          @stop = nil
          @thread = nil

          teardown
        end
      end

      def force_stop
        if @stop == :stop
          @stop = :force_stop
        else
          raise NotStopping, "Should call #stop first"
        end
      end

      def setup
      end

      def teardown
      end

      def main_loop
        while op = @queue.pop
          break if thread_should_stop?

          if op == :stop
            @stop = :stopable
          else
            perform op
          end

          break if thread_should_stop?
        end
      rescue Exception => e
        $stderr.puts "#{self.inspect} thread encountered an error: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
      end

      def thread_should_stop?
        @stop == :force_stop || @stop == :stopable
      end
    end
  end
end
