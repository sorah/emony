require 'emony/filters/base'
require 'socket'

module Emony
  module Filters
    class Hostname < Base
      def initialize(*)
        super

        raise ArgumentError, "@options[:key] is missing" unless @options[:key]
      end

      def key
        @options[:key]
      end

      def hostname
        Socket.gethostname
      end

      def new_value
        @new_value ||= {key => hostname}
      end

      def perform(record)
        new_value
      end
    end
  end
end
