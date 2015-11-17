module Emony
  class FilterChain
    def initialize(filters)
      @filters = filters
    end

    def filter(record)
      @filters.inject(record) do |r, filter|
        filter.filter(r).tap do |nr|
          unless Emony::Record === nr
            raise TypeError, "filter #{filter.class} returned #{nr.class}"
          end
        end
      end
    end
  end
end
