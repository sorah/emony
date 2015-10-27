require 'emony/utils/finder'

module Emony
  module Aggregators
    def self.find(name)
      Utils::Finder.find(self, 'emony/aggregators', name)
    end
  end
end
