require 'thread'

module Emony
  module TagMatching
    class Cache
      def initialize(max = 1000)
        @max = max
        @hash = {}
        @keys = []
        @lock = Mutex.new
      end

      def fetch(key)
        get(key) || set(key, yield)
      end

      def get(key)
        @hash[key]
      end

      def set(key, val)
        @lock.synchronize do
          exist = @hash.key?(key)
          @hash[key] = val
          unless exist
            @keys << key
            if @keys.size > @max
              @keys.shift(@keys.size-@max).each do |k|
                @hash.delete k
              end
            end
          end
        end
        val
      end
    end
  end
end
