require 'thread'
require 'emony/finalized_window'

module Emony
  class Window
    class Finalized < StandardError; end
    class NotApplicable < StandardError; end

    def initialize(start: , duration: , wait: 0, aggregators: {})
      @start = Time.at(start.to_i) # drop usec
      @duration = duration.to_i
      @wait = wait.to_i
      @aggregators = aggregators

      @lock = Mutex.new

      raise ArgumentError, "`wait` shouldn't be longer than `duration`" if @duration < @wait
    end

    attr_reader :start, :duration, :wait, :aggregators

    def id
      "#{start.to_i.to_s(36)}+#{duration}"
    end

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

    def add(record)
      raise NotApplicable unless applicable?(record) # XXX:
      @lock.synchronize do
        raise Finalized if finalized?
        aggregators.each do |k, agg|
          agg.add record
        end
      end
    end

    def merge(window)
      raise NotApplicable unless applicable_time?(window.start) && applicable_time?(window.finish)
      @lock.synchronize do
        raise Finalized if finalized?

        aggregators.each do |k, agg|
          agg.merge window.state[k] if window.state[k] # TODO: warn?
        end
      end
    end
  end
end
