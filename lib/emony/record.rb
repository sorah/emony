module Emony
  class Record
    def initialize(data, time_key: nil)
      @data = data
      @time_key = time_key
    end

    def time
      @time ||= parse_time
    end

    attr_reader :data

    def [](k)
      @data[k]
    end

    private

    def parse_time
      d = data[@time_key]
      case d
      when Time
        d
      when String
        Time.parse(d)
      when nil
        nil # TODO:
      else
        nil # TODO:
      end
    end
  end
end
