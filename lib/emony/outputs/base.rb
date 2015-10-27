module Emony
  module Outputs
    class Base
      # TODO: test
      def initialize(options = {})
        @options = options
        @config = @options[:config]
      end

      attr_reader :options, :config

      def setup
      end

      def teardown
      end

      def busy?
        false
      end

      def put(window)
        window = window.finalized_window
        send(window)
      end

      private

      def send(finalized_window)
        raise NotImplementedError
      end
    end
  end
end
