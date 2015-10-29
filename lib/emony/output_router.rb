require 'thread'
require 'emony/outputs'
require 'emony/tag_matching/matcher'

module Emony
  class OutputRouter
    class AlreadyRunning < StandardError; end
    class NotStopping < StandardError; end

    def initialize(outputs)
      @outputs = initialize_outputs(outputs)
      @matcher = TagMatching::Matcher.new(outputs.keys)

      @lock = Mutex.new
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

    def put(window)
      @queue << window
    end

    def perform_put(window)
      output = output_for_label(window.label)
      if output
        output.put(window)
      else
        # TODO: warn
      end
    end

    private

    def setup
      @outputs.each_value(&:setup)
    end

    def teardown
      @outputs.each_value(&:teardown)
    end

    def output_for_label(label)
      @outputs[@matcher.find(label)]
    end

    def initialize_outputs(outputs)
      outputs.map do |k,v|
        if v.kind_of?(Hash)
          [k.to_s,  Emony::Outputs.find(v[:type]).new(v)]
        else
          [k.to_s, v]
        end
      end.to_h
    end

    def main_loop
      while op = @queue.pop
        break if thread_should_stop?

        if op == :stop
          @stop = :stopable
        else
          window = op
          perform_put window
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
