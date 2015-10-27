require 'emony/outputs/base'
require 'json'

module Emony
  module Outputs
    class Stdout < Base
      def send(window)
        $stdout.puts [window.label, window.id, window.result.to_json].join("\t")
      end
    end
  end
end
