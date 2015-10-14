require 'emony/tag_matching/rules/base'
require 'emony/tag_matching/rules/any'
require 'emony/tag_matching/rules/glob'
require 'emony/tag_matching/rules/static'

module Emony
  module TagMatching
    module Rules
      def self.create(str)
        raise ArgumentError, 'str should be a String' unless str.is_a?(String)

        case str
        when '*', '$default'
          Any.new(str)
        when /\*/
          Glob.new(str)
        else
          Static.new(str)
        end
      end
    end
  end
end
