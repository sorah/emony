require 'emony/tag_matching/rules'
require 'emony/tag_matching/cache'
require 'emony/tag_parser'

require 'emony/label'

module Emony
  module TagMatching
    class Matcher
      def initialize(rules, cache: Cache.new)
        @rules = rules.map { |rule| rule.kind_of?(Rules::Base) ? rule : Rules.create(rule) }
        @cache = cache
      end
      
      def match?(tag)
        !!find(tag)
      end

      def find(tag_or_label)
        tag = case tag_or_label
              when Label
                tag_or_label.tag
              else
                TagParser.parse(tag_or_label)[:tag]
              end
        @cache.fetch(tag) do
          r = nil
          @rules.each do |rule|
            if rule.match?(tag)
              r = rule.to_s
              break
            end
          end
          r
        end
      end
    end
  end
end
