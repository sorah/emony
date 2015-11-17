require 'emony/record'

module Emony
  module Filters
    class Base
      def initialize(options = {})
        @options = options
      end

      def filter(record)
        res = perform(record)
        case res
        when Emony::Record
          res
        when Hash
          record.merge(res)
        else
          raise TypeError, "[BUG] #{self.class} filter method returned #{res.class} (Should be a kind of Hash or Emony::Record)"
        end
      end

      def perform(record)
        raise NotImplementedError
      end
    end
  end
end
