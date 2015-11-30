require 'emony/record'

module Emony
  module Sources
    class Base
      def initialize(options = {})
        @options = options
        @config = @options[:config]
      end

      attr_reader :options, :config
      attr_accessor :on_record, :on_window

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

      def merge_window(raw_window)
        return unless on_window

        window = case raw_window
        when Hash
          FinalizedWindow.from_hash(raw_window)
        when Array
          FinalizedWindow.from_array(raw_window)
        when FinalizedWindow
          raw_window
        when Window
          raw_window.finalized_window
        end

        on_window.call window
      end
    end
  end
end
