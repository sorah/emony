require 'emony/aggregators/base'
module Emony
  module Aggregators
    class Histogram < Base
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

      def width
        @options[:width]
      end

      def aggregate(record)
        return unless record[key]
        n = record[key].to_i
        div = n/width
        @data[width*div] += 1
      end

      def aggregate_merge(state)
        state.each do |k, v|
          @data[k.to_i] += v
        end
      end
    end
  end
end
