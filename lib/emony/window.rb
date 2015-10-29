require 'thread'
require 'emony/label'
require 'emony/finalized_window'
require 'emony/aggregators'

module Emony
  class Window
    class Finalized < StandardError; end
    class NotApplicable < StandardError; end

    def initialize(label, start: , duration: , wait: 0, allowed_gap: 0, aggregators: {})
      @label = Emony::Label(label)
      @start = Time.at(start.to_i) # drop usec
      @duration = duration.to_i
      @wait = wait.to_i
      @allowed_gap = allowed_gap.to_i

      @aggregators = aggregators.dup
      @aggregators.each do |k,v|
        if v.kind_of?(Hash)
          @aggregators[k] = Emony::Aggregators.find(v[:type]).new(v)
        end
      end

      @empty = true
      @lock = Mutex.new

      raise ArgumentError, "`wait` shouldn't be longer than `duration`" if @duration < @wait
    end

    attr_reader :label, :start, :duration, :wait, :aggregators, :allowed_gap

    def empty?
      @empty
    end

    def id
      @id ||= "#{start.to_i.to_s(36)}+#{duration}"
    end

    def inspect
      "#<Emony::Window[#{id}:#{wait}]#{finalized? ? ' finalized' : ''} start=#{start}>"
    end

    alias to_s inspect

    def finish
      @finish ||= @start + @duration
    end

    def deadline
      @deadline ||= finish + @wait
    end

    def state
      @lock.lock unless finalized?

      aggregators.map { |k, v|
        [k, v.state]
      }.to_h
    ensure
      @lock.unlock if @lock.owned?
    end

    def result
      @lock.lock unless finalized?

      aggregators.map { |k, v|
        [k, v.result]
      }.to_h
    ensure
      @lock.unlock if @lock.owned?
    end

    # XXX: finalized? closed?
    def finalized?
      deadline < Time.now
    end

    def waiting?
      start <= Time.now && finished? && !finalized?
    end

    def finished?
      finish <= Time.now
    end

    def finalized_window
      if finalized?
        FinalizedWindow.from_window self
      else
        nil
      end
    end

    # XXX: window requires loose check  but records aren't.
    def applicable_time?(time)
      start <= time && time <= finish
    end

    def applicable?(record)
      applicable_time? record.time
    end

    def applicable_window?(window)
      # TODO: test
      applicable_window_perfectly?(window) || applicable_window_on_gap?(window)
    end

    def applicable_window_perfectly?(window)
      applicable_time?(window.start) && applicable_time?(window.finish)
    end

    def applicable_window_on_gap?(window)
      gap_with_window(window).abs < @allowed_gap
    end

    def gap_with_window(window)
      return 0 if applicable_window_perfectly?(window)

      before_r = self.start - window.start
      after_r = window.finish - self.finish
      before = [0, before_r].min.abs
      after = [0, after_r].min.abs

      if before.zero? ^ after.zero?
        before + after
      else
        -(before_r.abs + after_r.abs)
      end
    end

    def add(record)
      raise NotApplicable unless applicable?(record) # XXX:
      @lock.synchronize do
        raise Finalized if finalized?
        aggregators.each do |k, agg|
          agg.add record
        end
        @empty = false
      end
    end

    def merge(window)
      raise NotApplicable unless applicable_window?(window)
      @lock.synchronize do
        raise Finalized if finalized?

        aggregators.each do |k, agg|
          agg.merge window.state[k] if window.state[k] # TODO: warn?
        end
        @empty = false
      end
    end
  end
end
