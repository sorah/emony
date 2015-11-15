module Emony
  module Utils
    module LtsvParser
      def self.parse(str)
        str.chomp.split(?\t).map { |_| _.split(?:, 2) }.reject { |_| _.size != 2 }.to_h
      end
    end
  end
end
