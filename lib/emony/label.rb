require 'emony/tag_parser'

module Emony
  def self.Label(obj)
    case obj
    when Label
      obj
    else
      Label.from_string obj.to_s
    end
  end

  class Label
    def self.from_string(string)
      self.new **TagParser.parse_label(string)
    end

    def initialize(tag: , group: nil, group_key: nil, duration: nil)
      @tag = tag
      @group = group
      @group_key = group_key
      @duration = duration && duration.to_i

      raise ArgumentError, "group and group_key should be both given if either is present" if @group.nil? ^ @group_key.nil?

      @group = @group.to_sym if @group
    end

    attr_reader :tag, :group, :group_key, :duration

    def primary?
      duration.nil?
    end

    def to_s
      @string ||= begin
        s = tag.dup
        s << "@#{duration}" if duration
        s << ":#{group}/#{group_key}" if group
        s
      end
    end

    def inspect
      "#<Emony::Label #{to_s.inspect}>"
    end

    def to_h
      {tag: @tag, group: @group, group_key: @group_key, duration: @duration}
    end

    def variant_with(**options)
      self.class.new **self.to_h.merge(options)
    end
  end
end
