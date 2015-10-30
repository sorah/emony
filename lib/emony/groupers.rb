require 'emony/utils/finder'

module Emony
  module Groupers
    def self.find(name)
      Utils::Finder.find(self, 'emony/groupers', name)
    end
  end
end
