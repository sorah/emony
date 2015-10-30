require 'emony/groupers/base'

module Emony
  module Groupers
    class Simple < Base
      # TODO: test
      def key
        @options[:key]
      end

      def determine(record)
        val = record[key]
        if val
          val.to_s
        else
          nil
        end
      end
    end
  end
end
