require 'emony/tag_matching/rules'

module Emony
  module TagMatching
    class Matcher
      def initialize(rules)
        @rules = rules.map { |rule| rule.kind_of?(Rules::Base) ? rule : Rules.create(rule) }
      end
      
      def match?(tag)
        !!find(tag)
      end

      def find(tag)
        @rules.each do |rule|
          return rule.to_s if rule.match?(tag)
        end
        nil
      end
    end
  end
end
