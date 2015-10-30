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
      @rule_matcher = TagMatching::Matcher.new(@hash[:aggregations].keys)
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
      # TODO: cache
      # XXX: to_sym
      if pattern
        # XXX: rule_matcher -> tag_matcher
        match = rule_name_for_tag(tag)
        if match
          @hash[:aggregations][match.to_sym]
        else
          if error
            raise ConfigurationMissing, "Missing configuration for label #{tag.inspect}"
          else
            nil
          end
        end
      else
        match = @hash[:aggregations][tag.to_sym]
        if match
          match
        else
          if error
            raise ConfigurationMissing, "Missing configuration for label #{tag.inspect}"
          else
            nil
          end
        end
      end
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
