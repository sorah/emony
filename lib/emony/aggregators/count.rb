require 'emony/aggregators/base'

module Emony
  module Aggregators
    class Count < Base
      def initialize(*)
        super
        @result = 0
      end

      alias state result

      def aggregate(data)
        @result += 1
      end

      def aggregate_merge(state)
        @result += state
      end
    end
  end
end
