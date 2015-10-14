require 'emony/tag_matching/rules/base'


module Emony
  module TagMatching
    module Rules
      class Glob < Base
        def initialize(pattern)
          @pattern = pattern
          @regexp = compile(pattern)
        end

        def match?(tag)
          @regexp === tag
        end

        def to_s
          @pattern
        end

        private

        def compile(pattern)
          pattern = pattern.split(?.)

          regexp_str = pattern.map { |x|
            case x
            when '**'
              ".+"
            when '*'
              "[^.]+?"
            else
              Regexp.escape(x)
            end
          }.join("\\.")

          /\A#{regexp_str}\z/
        end
      end
    end
  end
end
