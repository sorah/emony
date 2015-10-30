require 'thread'

module Emony
  class WindowSchedulerTicker # XXX; name
    TIMEOUT = 2

    class AlreadyRunning < StandardError; end

    def initialize(interval: 1)
      @set = Set.new
      @thread = nil
      @stop = false
      @lock = Mutex.new
      @interval = interval
    end

    def schedulers
      @set.to_a
    end

    def register(scheduler)
      # TODO: async
      @lock.synchronize do
        @set.add scheduler
      end
    end

    def deregister(scheduler)
      # TODO: async
      @lock.synchronize do
        @set.delete scheduler
      end
    end

    def running?
      @thread && @thread.alive?
    end

    def start
      @lock.synchronize do
        raise AlreadyRunning if running?

        @stop = false
        @thread = Thread.new(&method(:main_loop))
      end
      self
    end

    def stop
      @lock.synchronize do
        if running?
          @stop = true

          @thread.join(TIMEOUT)
          if @thread.alive?
            @thread.kill
          end
        end

        @thread = nil
        @stop = false
      end
      self
    end

    private

    def main_loop
      loop do
        break if @stop
        begin
          tick_all()
        rescue Exception => e
          $stderr.puts "#{self.inspect} thread encountered an error: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
        end
        break if @stop
        sleep @interval
      end
    end

    def tick_all
      @lock.synchronize do
        @set.each do |scheduler|
          scheduler.tick
        end
      end
    end
  end
end
