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
        # TODO: configuration validator
      end

      attr_reader :result, :state

      def finalized?
        @finalized
      end

      def finalize!
        @lock.synchronize do
          @finalized = true
        end
        self
      end

      def add(record)
        @lock.synchronize do
          raise Finalized if finalized?
          aggregate(record)
        end
        self
      end

      def merge(state)
        @lock.synchronize do
          raise Finalized if finalized?
          aggregate_merge(state)
        end
        self
      end

      private

      def aggregate_merge(state)
        raise NotImplementedError
      end

      def aggregate(record)
        raise NotImplementedError
      end
    end
  end
end
