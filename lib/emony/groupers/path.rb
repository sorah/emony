require 'emony/groupers/base'

module Emony
  module Groupers
    class Path < Base
      # TODO: test
      def key
        @options[:key]
      end

      def patterns
        @patterns ||= (@options[:patterns] || []).flat_map do |spec|
          case spec
          when String
            [[Regexp.new(spec), spec]]
          when Hash
            spec.map { |k,v| [Regexp.new(v), k] }
          end
        end
      end

      def default_level
        @default_level ||= @options[:default_level] ? @options[:default_level].to_i : 3
      end

      def determine(record)
        val = record[key]
        return unless val
        path = val.to_s
        return if path.empty?
        return path if path == '/'

        patterns.each do |regex, val|
          return val if regex === path
        end

        part = path.sub(%r{\A/}, '').sub(/\?.*\z/, '').split(?/)
        indicator = part.size > default_level ? '/...' : nil

        cut_part = part[0, default_level].map { |_| /\A\d+\z/ === _ ? 'XXX' : _ }
        [cut_part.join(?/).prepend(?/), indicator].join
      end
    end
  end
end
