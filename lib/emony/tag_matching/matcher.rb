require 'emony/tag_matching/rules'
require 'emony/tag_matching/cache'

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
        @cache.fetch(tag_or_label) do
          tag = tag_or_label.to_s.gsub(/(:.+)?(@\d+)?\z/, '') # XXX: TODO: use tag_parser
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
