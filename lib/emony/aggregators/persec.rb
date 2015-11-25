require 'emony/aggregators/base'

module Emony
  module Aggregators
    class Persec < Base
      def initialize(*)
        super

        @state = {count: 0, tail: nil, head: nil}
        @result = nil
      end

      def aggregate(record)
        @state[:count] += 1
        @state[:tail] = record.time if @state[:tail].nil? || record.time < @state[:tail]
        @state[:head] = record.time if @state[:head].nil? || @state[:head] < record.time
        calculate!
      end

      def aggregate_merge(state)
        tail = state[:tail] || state['tail']
        head = state[:head] || state['head']
        count = state[:count] || state['count']

        if @state[:tail].nil? || tail < @state[:tail]
          @state[:tail] = tail
        end
        if @state[:head].nil? || @state[:head] < head
          @state[:head] = head
        end
        @state[:count] += count || 0

        calculate!
      end

      private

      def calculate!
        if @state[:count] && @state[:head] && @state[:tail]
          duration = @state[:head] - @state[:tail]
          if duration > 0
            persec = @state[:count] / duration
            @result = {duration: duration, persec: persec}
          end
        end
      end
    end
  end
end
