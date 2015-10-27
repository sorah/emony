require 'emony/utils/finder'

module Emony
  module Outputs
    def self.find(name)
      Utils::Finder.find(self, 'emony/outputs', name)
    end
  end
end
