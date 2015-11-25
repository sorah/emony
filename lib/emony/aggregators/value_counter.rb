require 'emony/aggregators/base'
module Emony
  module Aggregators
    class ValueCounter < Base
      def initialize(*)
        super

        @data = Hash.new(0)
      end

      def result
        @data.to_a.sort_by(&:first)
      end

      def state
        @data
      end

      def key
        @options[:key]
      end

      def aggregate(record)
        val = record[key]
        return unless val
        @data[val.to_s] += 1
      end

      def aggregate_merge(state)
        state.each do |k, v|
          @data[k.to_s] += v
        end
      end
    end
  end
end
