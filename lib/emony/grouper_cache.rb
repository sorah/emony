require 'emony/groupers'

module Emony
  class GrouperCache
    def initialize(config)
      @config = config
      @rules = {}
    end

    def tag(tag)
      rulename = @config.rule_name_for_tag(tag)
      if rulename
        rulebody = @config.aggregation_rule_for_tag(rulename, pattern: false)

        rule rulename, rulebody
      else
        nil
      end
    end

    def rule(name, rule)
      @rules[name] ||= begin
        (rule[:groups] || {}).map do |k, v|
          Groupers.find(v[:type]).new(k, v)
        end
      end
    end
  end
end
