require 'emony/label'

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

    def self.from_array(ary)
      raise ArgumentError, "missing values" if ary.size < 6
      new(
        label: ary[0],
        id: ary[1],
        start: Time.at(ary[2]),
        duration: ary[3],
        state: ary[4],
        result: ary[5],
        check_merge_applicability: ary[6],
      )
    end

    def self.from_hash(hash)
      start = hash['start'].kind_of?(Time) ? hash['start'] : Time.at(hash['start'].to_i)
      new(
        label: hash['label'],
        id: hash['id'],
        start: start,
        duration: hash['duration'],
        state: hash['state'],
        result: hash['result'],
        check_merge_applicability: hash['check_merge_applicability'],
      )
    end

    def initialize(label: , id: , start: , duration: , state: , result: , check_merge_applicability: )
      @label = label && Emony::Label(label)
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

    def to_h
      {
        label: label,
        id: id,
        start: start.to_i,
        duration: duration,
        state: state,
        result: result,
        check_merge_applicability: check_merge_applicability?,
      }
    end

    def to_a
      [
        label,
        id,
        start.to_i,
        duration,
        state,
        result,
        check_merge_applicability?,
      ]
    end

    attr_reader :label, :id, :start, :duration, :state, :result
  end
end
