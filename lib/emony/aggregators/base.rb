require 'thread'

module Emony
  module Aggregators
    class Base
      class Finalized < StandardError; end

      def initialize(options = {})
        @options = options

        @lock = Mutex.new
        @finalized = false

        @result = nil
        @state = nil
      end

      attr_reader :result, :state

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

      def merge(state)
        @lock.synchronize do
          raise Finalized if finalized?
          aggregate_merge(state)
        end
      end

      private

      def aggregate_merge(state)
        raise NotImplementedError
      end

      def aggregate(data)
        raise NotImplementedError
      end
    end
  end
end
