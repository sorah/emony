module Emony
  class FinalizedWindow
    def self.from_window(window)
      new(
        label: window.label,
        id: window.id,
        start: window.start,
        duration: window.duration,
        state: window.state,
        result: window.result,
        check_merge_applicability: window.check_merge_applicability?,
      )
    end

    def initialize(label: , id: , start: , duration: , state: , result: , check_merge_applicability: )
      @label = label
      @id = id
      @start = start
      @duration = duration
      @state = state
      @result = result
      @check_merge_applicability = check_merge_applicability

      raise "missing values" unless @label && @id && @start && @duration && @state && @result
    end

    def check_merge_applicability?
      @check_merge_applicability
    end

    def finish
      @start + @duration
    end

    def finalized_window
      self
    end

    attr_reader :label, :id, :start, :duration, :state, :result
  end
end
