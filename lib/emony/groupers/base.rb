require 'emony/label'

module Emony
  module Groupers
    class Base
      # TODO: test

      def initialize(name, options = {})
        @name = name
        @options = options
        # TODO: configuration validator
      end

      def determine_group_label(record)
        key = determine(record)
        if key
          Emony::Label(record.tag).variant_with(group: @name, group_key: key)
        else
          nil
        end
      end

      def determine(record)
        raise NotImplementedError
      end
    end
  end
end
