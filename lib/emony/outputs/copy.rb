require 'emony/outputs/base'
require 'emony/outputs'

module Emony
  module Outputs
    class Copy < Base
      def initialize(*)
        super
        outputs = @options[:outputs] || []

        @outputs = outputs.map do |v|
          raise ArgumentError, "output should be a kind of Hash" unless v.kind_of?(Hash)
          Emony::Outputs.find(v[:type]).new(v)
        end
      end

      def send(window)
        @outputs.each do |v|
          v.put(window)
        end
      end
    end
  end
end
