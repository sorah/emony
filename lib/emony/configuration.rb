require 'yaml'
require 'emony/tag_matching/matcher'

module Emony
  class Configuration
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

    def aggregation_rule_for_tag(tag, pattern: true)
      # TODO: cache
      # XXX: to_sym
      if pattern
        match = @rule_matcher.find(tag)
        if match
          @hash[:aggregations][match.to_sym]
        else
          nil
        end
      else
        @hash[:aggregations][tag.to_sym]
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
