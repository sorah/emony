require 'emony/tag_matching/rules/base'

module Emony
  module TagMatching
    module Rules
      class Any < Base
        def initialize(str)
          @str = str
        end

        def match?(tag)
          true
        end

        def to_s
          @str
        end
      end
    end
  end
end
