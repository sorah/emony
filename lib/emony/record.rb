module Emony
  class Record
    def initialize(data, time_key: nil, time: nil, tag: nil, config: nil)
      @data = data
      @tag = tag
      @time = time
      @imported_time = Time.now

      unless @time
        if @time_key
          @time_key = time_key || determine_time_key(config)
        else
          @time = Time.now
        end
      end
    end

    attr_reader :imported_time

    # TODO: test

    def time
      @time ||= parse_time
    end

    attr_reader :data, :tag, :time_key

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
        Time.parse(d)
      else
        raise "[BUG] parse_time called with #{d.inspect}"
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
