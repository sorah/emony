require 'emony/utils/finder'

module Emony
  module Sources
    def self.find(name)
      Utils::Finder.find(self, 'emony/sources', name)
    end
  end
end
