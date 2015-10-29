require 'thread'
require 'emony/utils/operation_threadable'
require 'emony/outputs'
require 'emony/tag_matching/matcher'

module Emony
  class OutputRouter
    include Emony::Utils::OperationThreadable

    def initialize(outputs)
      @outputs = initialize_outputs(outputs)
      @matcher = TagMatching::Matcher.new(outputs.keys)

      @lock = Mutex.new
      init_operation_threading
    end
    
    def put(window)
      @queue << window
    end

    def perform(op)
      perform_put op
    end

    def perform_put(window)
      output = output_for_label(window.label)
      if output
        output.put(window)
      else
        # TODO: warn
      end
    end

    private

    def setup
      @outputs.each_value(&:setup)
    end

    def teardown
      @outputs.each_value(&:teardown)
    end

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
