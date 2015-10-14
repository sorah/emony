require 'thread'
require 'emony/window'

module Emony
  class WindowScheduler
    def initialize(specification)
      @lock = Mutex.new
      @specification = specification
      @on_result = proc { }

      @active, @waiting = new_window, nil
      tick
    end

    attr_reader :active, :waiting, :specification

    def on_result(&block)
      @on_result = block
    end

    def add(record)
      @lock.synchronize do
        tick

        if waiting && waiting.applicable?(record)
          waiting.add(record)
        else
          active.add(record)
        end
      end
    end

    def merge(window)
      @lock.synchronize do
        tick

        if waiting && waiting.applicable_window?(window)
          waiting.merge(window)
        else
          active.merge(window)
        end
      end
    end

    def tick
      locked = if @lock.owned?
        false
      else
        @lock.lock
        true
      end

      # TODO: when tick couldn't run continously, window may have lacked

      if @waiting && @waiting.finalized?
        @on_result.call(@waiting) unless @waiting.empty?
        @waiting = nil
      end

      case
      when @active.finalized?
        @on_result.call(@active) unless @active.empty?
        @active = nil
      when @active.waiting?
        @waiting = @active
        @active = nil
      end

      @active ||= new_window

      nil
    ensure
      @lock.unlock if locked
    end

    private

    def new_window(time: Time.now)
      Window.new(start: time, **specification)
    end
  end
end
