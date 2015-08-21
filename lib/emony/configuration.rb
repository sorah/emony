require 'yaml'

module Emony
  class Configuration
    def self.load_file(path)
      self.new YAML.load_file(path)
    end

    def initialize(hash={})
      @hash = symbolize_keys!(hash)
    end

    def [](k)
      @hash[k]
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
