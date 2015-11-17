require 'emony/utils/finder'

module Emony
  module Filters
    def self.find(name)
      Utils::Finder.find(self, 'emony/filters', name)
    end
  end
end
