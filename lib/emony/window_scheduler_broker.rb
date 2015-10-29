require 'thread'
require 'emony/label'
require 'emony/window_scheduler'

module Emony
  class WindowSchedulerBroker # XXX: naming
    def initialize(config, ticker)
      @config = config
      @ticker = ticker

      @on_new_window_scheduler = proc {}
      @schedulers = {}
      @lock = Mutex.new
    end

    attr_reader :config
    attr_accessor :on_new_window_scheduler

    # TODO: GC

    def get(label)
      label = Emony::Label(label)
      @schedulers[label.to_s] || create(label)
    end

    def get_for_subwindows(label) # XXX: naming
      # XXX: do this in configuration?
      if label.primary?
        (config.aggregation_rule_for_tag(label, error: true)[:sub_windows] || []).map do |window_spec|
          label = Emony::Label(label).variant_with(duration: window_spec[:duration])
          get(label)
        end
      else
        []
      end
    end

    private

    def create(label)
      @lock.synchronize do
        return @schedulers[label.to_s] if @schedulers[label.to_s]

        specification = @config.window_specification_for_label(label)

        @schedulers[label.to_s] = sched = WindowScheduler.new(label, specification)
        @on_new_window_scheduler.call sched
        @ticker.register sched

        sched
      end
    end
  end
end
