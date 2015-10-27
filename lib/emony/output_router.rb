require 'emony/outputs'
require 'emony/tag_matching/matcher'

module Emony
  class OutputRouter
    # TODO: test
    def initialize(outputs)
      @outputs = initialize_outputs(outputs)
      @matcher = TagMatching::Matcher.new(outputs.keys)
    end

    def setup
      @outputs.each_value(&:setup)
    end

    def teardown
      @outputs.each_value(&:teardown)
    end

    def put(window)
      output = output_for_label(window.label)
      if output
        output.put(window)
      else
        # TODO: warn
      end
    end

    private

    def output_for_label(label)
      @outputs[@matcher.find(label)]
    end

    def initialize_outputs(outputs)
      outputs.map do |k,v|
        if v.kind_of?(Hash)
          [k.to_s,  Emony::Outputs.find(v[:type]).new(v)]
        else
          [k.to_s, v]
        end
      end.to_h
    end
  end
end
