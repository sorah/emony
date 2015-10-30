require 'thread'
require 'emony/utils/operation_threadable'

module Emony
  # Route message (record or finalized_window) to proper window_scheduler. Also this calls grouper to create subgroups
  class MessageRouter
    include Emony::Utils::OperationThreadable
    # TODO: test

    def initialize(window_scheduler_broker, grouper_cache)
      @broker = window_scheduler_broker
      @grouper_cache = grouper_cache

      @lock = Mutex.new
      init_operation_threading
    end

    def add(record)
      @queue << [:add, record]
    end

    def merge(window)
      @queue << [:merge, window]
    end

    def propagate(window)
      @queue << [:propagate, window]
    end

    def perform(op)
      case op[0]
      when :add
        perform_add op[1]
      when :merge
        perform_merge op[1]
      when :propagate
        perform_propagate op[1]
      else
        raise '[BUG] unknown op'
      end
    end

    def perform_add(record)
      begin
        @broker.get(record.tag).add(record)
      rescue Emony::Window::NotApplicable, Emony::Window::Finalized => e
        warn "WARN: #{record.tag} #{e.inspect}"
      end

      @grouper_cache.tag(record.tag).each do |grouper|
        group_label = grouper.determine_group_label(record)
        if group_label
          begin
            @broker.get(group_label).add(record)
          rescue Emony::Window::NotApplicable, Emony::Window::Finalized => e
            warn "WARN: #{record.tag} #{e.inspect}"
          end
        end
      end
    end

    def perform_merge(window)
      # TODO: implement perform_merge
    end

    def perform_propagate(window)
      @broker.get_for_subwindows(window.label, init_time: window.start).each do |scheduler|
        begin
          scheduler.merge window
        rescue Emony::Window::NotApplicable
          warn "WARN: #{window} -> #{scheduler} not applicable!"
        end
      end
    end
  end
end
