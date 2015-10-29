require 'thread'

require 'emony/sources'
require 'emony/message_router'
require 'emony/output_router'
require 'emony/window_scheduler_ticker'
require 'emony/window_scheduler_broker'

module Emony
  class Engine
    def initialize(config)
      @config = config
      @ready = false
      @stop = Queue.new
    end

    attr_reader :config

    def prepare
      return if @ready
      sources
      window_scheduler_ticker
      window_scheduler_broker
      output_router
      @ready = true
    end

    def run
      raise "[BUG] have to prepared" unless @ready

      output_router.start
      window_scheduler_ticker.start
      message_router.start
      sources.each(&:start)

      @stop.pop

      # sources.map { |s| Thread.new(s, &:stop) }.each(&:join)
      sources.each(&:stop)
      message_router.stop
      window_scheduler_ticker.stop
      output_router.stop
    ensure
      teardown
    end

    def teardown
    end

    def stop
      @stop << true
    end

    def on_record(record)
      message_router.add record
    end

    def on_new_window_scheduler(scheduler)
      scheduler.on_result &method(:on_finalized_window)
    end

    def on_finalized_window(window)
      output_router.put window
    end

    def sources
      @sources ||= config[:sources].map do |v|
        Sources.find(v[:type]).new(v.merge(config: @config)).tap do |source|
          source.on_record = method(:on_record)
        end
      end
    end

    def window_scheduler_ticker
      @window_scheduler_ticker ||= WindowSchedulerTicker.new(interval: @config[:tick_interval] || 1)
    end

    def window_scheduler_broker
      @window_scheduler_broker ||= WindowSchedulerBroker.new(@config, window_scheduler_ticker).tap do |broker|
        broker.on_new_window_scheduler = method(:on_new_window_scheduler)
      end
    end

    def message_router
      @message_router ||= MessageRouter.new(window_scheduler_broker)
    end

    def output_router
      @output_router ||= OutputRouter.new(config[:outputs])
    end
  end
end
