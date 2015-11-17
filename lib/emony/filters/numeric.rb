require 'emony/filters/base'

module Emony
  module Filters
    class Numeric < Base
      def initialize(*)
        super

        raise ArgumentError, "@options[:key] is missing" unless @options[:key]
        @options[:result_in_float] = @options[:float] unless @options.has_key?(:result_in_float)
        @options[:skip_nil] = true unless @options.has_key?(:skip_nil)
      end

      def key
        @options[:key]
      end

      def float?
        @options[:float]
      end

      def result_in_float?
        @options[:result_in_float]
      end

      def skip_nil?
        @options[:skip_nil]
      end

      def ops
        @ops ||= [*(@options[:ops] || @options[:op] || [])]
      end

      def perform(record)
        value = record[key]

        if !value
          if skip_nil?
            return {}
          else
            raise ArgumentError, "Value required for key #{key.inspect}"
          end
        end

        # prepare input
        implicit_float = float? == nil && value.kind_of?(Float)
        value = if implicit_float
                  value
                else
                  float? ? value.to_f : value.to_i
                end

        # do some op
        ops.each do |op|
          op.each do |type, val|
            value = perform_op(value, type, val)
          end
        end

        # prepare output
        value = if implicit_float && result_in_float? == nil
          value
        else
          result_in_float? ? value.to_f : value.to_i
        end

        {key => value}
      end

      private

      def perform_op(value, op, other)
        case op
        when :add
          value + other
        when :subtract
          value - other
        when :multiply
          value * other
        when :divide
          value / other
        end
      end
    end
  end
end
