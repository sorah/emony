module Emony
  class Record
    def initialize(data, time_key: nil, time_parser: nil, time: nil, tag: nil, config: nil)
      @data = data
      @tag = tag
      @time = time
      @imported_time = Time.now

      unless @time
        @time_key = time_key || determine_time_key(config)
        @time_parser = time_parser == false ? nil : (time_parser || determine_time_parser(config)) # XXX:
      end
    end

    attr_reader :imported_time

    # TODO: test

    def time
      @time ||= parse_time || imported_time
    end

    attr_reader :data, :tag, :time_key, :time_parser

    def [](k)
      @data[k]
    end

    def merge(h)
      self.class.new(@data.merge(h), time: time, tag: tag)
    end

    private

    def parse_time
      d = data[@time_key]

      case d
      when Time
        d
      when String
        if time_parser
          time_parser.exec(d)
        else
          Time.parse(d)
        end
      when Integer
        Time.at(d)
      else
        # raise "[BUG] parse_time called with #{d.inspect}"
        nil
      end
    end

    def determine_time_parser(config)
      if config
        config.time_parser_for_tag(@tag)
      else
        nil
      end
    end

    def determine_time_key(config)
      if config
        rule = config.aggregation_rule_for_tag(@tag)
        rule && rule[:time]
      else
        nil
      end
    end
  end
end
