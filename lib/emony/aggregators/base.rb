require 'thread'

module Emony
  module Aggregators
    class Base
      class Finalized < StandardError; end

      def initialize(options = {})
        self.class.validate!

        @lock = Mutex.new
        @finalized = false

        @result = nil
      end

      attr_reader :result

      def finalized?
        @finalized
      end

      def finalize!
        @lock.synchronize do
          @finalized = true
        end
      end

      def add(data)
        @lock.synchronize do
          raise Finalized if finalized?
          aggregate(data)
        end
      end

      def merge(data)
        @lock.synchronize do
          raise Finalized if finalized?
          aggregate_merge(data)
        en
      end

      private

      def aggregate_merge(data)
        raise NotImplementedError
      end

      def aggregate(data)
        raise NotImplementedError
      end
      end
    end
  end
end
