require 'emony/filters'
require 'emony/filters/base'
require 'emony/filter_chain'

module Emony
  class FilterChainCache
    def initialize(config)
      @config = config
      @chains = {}
    end

    def tag(tag)
      rulename = @config.filter_rule_name_for_tag(tag)
      if rulename
        rule rulename
      else
        nil
      end
    end

    def rule(rulename)
      @chains[rulename] ||= begin
        filters = @config[:filters][rulename.to_sym].map do |v|
          Filters.find(v[:type]).new(v)
        end
        FilterChain.new(filters)
      end
    end
  end
end
