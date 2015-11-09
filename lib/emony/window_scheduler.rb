require 'thread'
require 'emony/window'
require 'emony/label'

module Emony
  class WindowScheduler
    # TODO: fix timing of window start on initialize
    def initialize(label, specification, init_time: nil)
      @lock = Mutex.new
      @label = Emony::Label(label)
      @specification = { check_merge_applicability: false }.merge(specification)
      @on_result = proc { }
      @on_no_recent_record = proc { }
      @init_time = init_time

      @empty_window_count = 0

      @active, @waiting = new_window(time: @init_time || Time.now), nil
      tick
    end

    attr_reader :label, :active, :waiting, :specification

    def inspect
      "#<#{self.class}[#{label}] active=#{active.inspect} waiting=#{waiting.inspect}>"
    end
    alias to_s inspect

    def on_result(&block)
      @on_result = block
    end

    def on_no_recent_record(&block)
      @on_no_recent_record = block
    end

    def add(record)
      retried ||= false

      @lock.synchronize do
        tick

        if waiting && waiting.applicable?(record)
          waiting.add(record)
        else
          active.add(record)
        end
      end
    rescue Emony::Window::Finalized, Emony::Window::NotApplicable
      unless retried
        retried = true
        #warn "WARN: Retry #{$!.inspect}"
        retry
      end

      raise
    end

    def merge(window)
      retried ||= false

      @lock.synchronize do
        tick

        if waiting && waiting.applicable_window?(window)
          waiting.merge(window)
        else
          active.merge(window)
        end
      end
    rescue Emony::Window::Finalized, Emony::Window::NotApplicable
      unless retried
        retried = true
        #warn "WARN: Retry #{$!.inspect}"
        retry
      end

      raise
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
