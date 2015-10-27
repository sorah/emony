module Emony
  class FinalizedWindow
    def self.from_window(window)
      new(label: window.label, id: window.id, start: window.start, duration: window.duration, state: window.state, result: window.result)
    end

    def initialize(label: , id: , start: , duration: , state: , result: )
      @label, @id, @start, @duration, @state, @result = label, id, start, duration, state, result
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
