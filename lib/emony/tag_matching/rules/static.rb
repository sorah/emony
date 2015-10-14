require 'emony/tag_matching/rules/base'

module Emony
  module TagMatching
    module Rules
      class Static < Base
        def initialize(tag)
          @tag = tag
        end

        def to_s
          @tag
        end

        def match?(tag)
          tag == @tag
        end
      end
    end
  end
end
