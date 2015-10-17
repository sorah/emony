module Emony
  module TagParser
    class ValidationError < StandardError; end

    def self.parse(tag_or_label)
      tag_or_label = tag_or_label.to_s

      # TODO: validate group name
      m = tag_or_label.match(/\A(?<tag>[^:@$+\/]+?)(?:@(?<duration>\d+))?(?::(?<group>.+?)\/(?<group_key>.+))?\z/)
      unless m
        raise ValidationError, "#{tag_or_label.inspect} is invalid"
      end

      if m[:duration] || m[:group] || m[:group_key]
        {tag: m[:tag], group: m[:group], group_key: m[:group_key], duration: m[:duration] && m[:duration].to_i}
      else
        {tag: m[:tag]}
      end
    end

    def self.parse_tag(tag)
      tag = tag.to_s
      raise ValidationError, "tag #{tag.inspect} is invalid" if tag.match(/[:@$+\/]/)

      {tag: tag}
    end

    def self.parse_label(label)
      parse(label)
    end
  end
end
