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
      @op_queue = Queue.new
      @interval = interval
    end

    def schedulers
      @set.to_a
    end

    def register(scheduler)
      @op_queue << [:register, scheduler]
    end

    def deregister(scheduler)
      @op_queue << [:deregister, scheduler]
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

    def perform_ops
      while op = @op_queue.pop(:nonblock)
        case op[0]
        when :deregister
          @set.delete op[1]
        when :register
          @set.add op[1]
        else
          raise '[BUG] unknown op'
        end
      end
    rescue ThreadError
    end

    private

    def main_loop
      loop do
        break if @stop
        begin
          perform_ops()
          tick_all()
        rescue Exception => e
          $stderr.puts "#{self.inspect} thread encountered an error: #{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
        end
        break if @stop
        sleep @interval
      end
    end

    def tick_all
      @set.each do |scheduler|
        scheduler.tick
      end
    end
  end
end
