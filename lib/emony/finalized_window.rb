module Emony
  class FinalizedWindow
    def self.from_window(window)
      new(id: window.id, start: window.start, duration: window.duration, state: window.state, result: window.result)
    end

    def initialize(id: , start: , duration: , state: , result: )
      @id, @start, @duration, @state, @result = id, start, duration, state, result
    end

    def finish
      @start + @duration
    end

    attr_reader :id, :start, :duration, :state, :result
  end
end
