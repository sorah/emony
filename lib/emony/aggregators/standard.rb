require 'emony/aggregators/base'

module Emony
  module Aggregators
    class Standard < Base
      def initialize(*)
        super

        @data = {total: 0, count: 0, average: nil, min: nil, max: nil}
      end

      def result
        @data
      end

      def state
        @data
      end

      def key
        @options[:key]
      end

      def aggregate(record)
        return unless record[key]
        n = record[key].to_i
        @data[:total] += n
        @data[:count] += 1

        calculate(min: n, max: n)
      end

      def aggregate_merge(state)
        @data[:total] += state[:total]
        @data[:count] += state[:count]

        calculate(min: state[:min], max: state[:max])
      end

      private

      def calculate(min: nil, max: nil)
        @data[:average] = @data[:total] / @data[:count]

        if @data[:min]
          @data[:min] = min if min && min < @data[:min]
        elsif min
          @data[:min] = min
        end

        if @data[:max]
          @data[:max] = max if max && @data[:max] < max
        elsif max
          @data[:max] = max
        end
      end
    end
  end
end
