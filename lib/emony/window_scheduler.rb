require 'thread'
require 'emony/window'
require 'emony/label'

module Emony
  class WindowScheduler
    def initialize(label, specification)
      @lock = Mutex.new
      @label = Emony::Label(label)
      @specification = specification
      @on_result = proc { }
      @on_no_recent_record = proc { }

      @empty_window_count = 0

      @active, @waiting = new_window, nil
      tick
    end

    attr_reader :label, :active, :waiting, :specification

    def on_result(&block)
      @on_result = block
    end

    def on_no_recent_record(&block)
      @on_no_recent_record = block
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
        make_result(@waiting)
        @waiting = nil
      end

      case
      when @active.finalized?
        make_result(@active)
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
      Window.new(label, start: time, **specification)
    end

    def make_result(window)
      if window.empty?
        @empty_window_count += 1
        if @empty_window_count > 1
          @on_no_recent_record.call
        end
      else
        @empty_window_count = 0
        @on_result.call(window)
      end
    end
  end
end
