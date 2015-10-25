require 'emony/record'

module Emony
  module Sources
    class Base
      def initialize(options = {})
        @options = options
        @config = @options[:config]
      end

      attr_reader :options, :config
      attr_accessor :on_record

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
        record = Emony::Record.new(data, tag: tag, config: @config)
        if on_record
          on_record.call record
        end
      end
    end
  end
end
