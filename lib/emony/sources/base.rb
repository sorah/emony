require 'emony/record'

module Emony
  module Sources
    class Base
      def initialize(options = {})
        @options = options
        @config = @options[:config]
      end

      attr_reader :options, :config

      def start
        raise NotImplementedError
      end

      def stop
        raise NotImplementedError
      end

      def running?
        raise NotImplementedError
      end

      private

      def create_record(tag, data)
        Emony::Record.new(data, tag: tag, config: @config)
      end
    end
  end
end
