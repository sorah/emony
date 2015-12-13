require 'yaml'
require 'emony/tag_matching/matcher'
require 'emony/tag_parser'

module Emony
  class Configuration
    class ConfigurationMissing < StandardError; end

    def self.load_file(path)
      self.new YAML.load_file(path)
    end

    def initialize(hash={})
      @hash = symbolize_keys!(hash)
      @hash[:aggregations] ||= {}
      @hash[:filters] ||= {}

      @rule_matcher = TagMatching::Matcher.new(@hash[:aggregations].keys)
      @filter_rule_matcher = TagMatching::Matcher.new(@hash[:filters].keys)
    end

    def [](k)
      @hash[k]
    end

    # XXX:
    def window_specification_for_label(label)
      rule = aggregation_rule_for_tag(label, error: true)

      window_rule = if label.duration
                      (rule[:sub_windows] || []).find { |_| _[:duration].to_i == label.duration }
                    else
                      rule[:window]
                    end

      {
        aggregators: rule[:items] || {},
      }.merge(window_rule)
    end

    def rule_name_for_tag(tag)
      @rule_matcher.find(tag)
    end

    def aggregation_rule_for_tag(tag, pattern: true, error: false)
      # XXX: to_sym
      rule = if pattern
        # XXX: rule_matcher -> tag_matcher
        match = rule_name_for_tag(tag)
        match && @hash[:aggregations][match.to_sym]
      else
        @hash[:aggregations][tag.to_sym]
      end

      if error && rule.nil?
        raise ConfigurationMissing, "Missing configuration for label #{tag.inspect}"
      end

      rule
    end

    def filter_rule_name_for_tag(tag) # TODO: test
      @filter_rule_matcher.find(tag)
    end

    def filter_rule_for_tag(tag) # TODO: test
      name = filter_rule_name_for_tag(tag)
      name && @hash[:filters][name]
    end

    private

    def symbolize_keys!(obj)
      case obj
      when Hash
        Hash[obj.map { |k, v| [k.is_a?(String) ? k.to_sym : k, symbolize_keys!(v)] }]
      when Array
        obj.map { |v| symbolize_keys!(v) }
      else
        obj
      end
    end
  end
end
