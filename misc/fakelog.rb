#!/usr/bin/env ruby
require 'json'

$stdout.sync = true

module Fakelog
  module SpeedModifiers
    class Sin
      def initialize(options = {})
        @base = options[:base] || 1800
        @i = 1
      end

      def tick
        @i += 1
        warn "SpeedModifier::Sin[#{@i}]: #{base}"
      end

      def base
        (Math.sin(@i * 0.05).abs * @base).round.succ
      end

      def value
        base + rand(12)
      end
    end
  end

  module InformationGenerators
    class GenericPath
      def initialize(*)
      end

      def tick
      end

      DIC = %w(
        recipes feedbacks users comments friends statuses posts articles commits
        blob branches tree releases issues pulls
      )

      def path
        case rand(2)
        when 0
          "/#{DIC.sample}"
        when 1
          "/#{DIC.sample}/#{rand(10000)}"
        when 2
          rand(5).succ.times.map { DIC.sample }.join(?/).prepend(?/)
        when 3
          rand(6).succ.times.map { |i| i.odd? ? rand(10000).to_s : DIC.sample }.join(?/).prepend(?/)
        end
      end

      def value
        {
          path: path
        }
      end
    end

    class GenericReqtime
      def initialize(*)
        @i = 1
      end

      def tick
        @i += 1
        #warn "GenericReqtime[#{@i}]: base #{base}"
      end

      def base
        (Math.sin(@i * 0.05).abs * 100).round
      end

      def reqtime
        i = base()
        i += rand(80)
        if (@i / 100) % 10 == 0
          warn "bursting"
          i += 1500 + (rand(300) * (rand(2) == 1 ? -1 : 1))
        end
        warn "!!!!!!!!!!!! #{i}" if i < 0
        i
      end

      def value
        {reqtime: reqtime}
      end
    end
  end

  module Scinarios
    class Base
      def initialize(options = {})
        @options = options
        @speed_modifier = self.class.speed_modifier(@options[:speed_modifier] || {})
        @information_generators = self.class.information_generators(@options[:information_generators] || {})
        @i = 1
      end

      def self.speed_modifier(options)
        SpeedModifiers::Sin.new(options)
      end

      def self.information_generators(options)
        []
      end

      attr_reader :speed_modifier, :information_generators

      def tick
        @i += 1
        speed_modifier.tick
      end

      def generate
        tick
        t = Time.now
        speed_modifier.value.times.map do
          information_generators.inject({}) { |r,g| r.merge!(g.value); g.tick; r }.merge(time: t)
        end
      end
    end

    class Default < Base
      def self.information_generators(options)
        [InformationGenerators::GenericPath.new, InformationGenerators::GenericReqtime.new]
      end
    end
  end

  class Core
    def initialize(scinario)
      @scinario = Scinarios::Default.new
    end

    def run
      loop do
        @scinario.generate.each do |x|
          puts x.to_json
        end
        sleep 1
      end
    end
  end
end

Fakelog::Core.new(nil).run
