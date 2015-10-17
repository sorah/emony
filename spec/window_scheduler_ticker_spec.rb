require 'spec_helper'

require 'emony/window_scheduler_ticker'

describe Emony::WindowSchedulerTicker do
  let(:scheduler_a) { double('scheduler_a', tick: nil) }
  let(:scheduler_b) { double('scheduler_b', tick: nil) }

  subject(:ticker) { described_class.new(interval: 0.01) }

  after do
    ticker.stop
  end

  describe "#register" do
    it "adds scheduler" do
      expect(ticker.schedulers).to eq([])
      ticker.register scheduler_a
      expect(ticker.schedulers).to eq([scheduler_a])
    end
  end

  describe "#deregister" do
    before do
      ticker.register scheduler_a
      ticker.register scheduler_b
    end
    it "removes scheduler" do
      ticker.deregister scheduler_b
      expect(ticker.schedulers).to eq([scheduler_a])
    end
  end

  describe "#start" do
    context "when it is already running" do
      it "raises error" do
        ticker.start
        expect { ticker.start }.to raise_error(Emony::WindowSchedulerTicker::AlreadyRunning)
      end
    end
  end

  describe "scinarios:" do
    it "can start and stop" do
      ticker.start
      expect(ticker).to be_running
      ticker.stop
      expect(ticker).not_to be_running
    end

    it "ticks all registered schedulers" do
      a = 0
      allow(scheduler_a).to receive(:tick) { a += 1 }
      b = 0
      allow(scheduler_b).to receive(:tick) { b += 1 }

      ticker.register scheduler_a
      ticker.register scheduler_b

      ticker.start
      100.times { break if a > 0 && b > 0; sleep 0.01 }

      expect(a).to be >= 1
      expect(b).to be >= 1
    end

    it "ticks registered schedulers which registered after its start" do
      a = 0
      allow(scheduler_a).to receive(:tick) { a += 1 }
      b = 0
      allow(scheduler_b).to receive(:tick) { b += 1 }

      ticker.register scheduler_a

      ticker.start
      100.times { break if a > 0; sleep 0.01 }

      ticker.register scheduler_b
      100.times { break if b > 0; sleep 0.01 }

      expect(a).to be >= 1
      expect(b).to be >= 1
    end

    it "ticks deregistered schedulers which deregistered after its start" do
      a = 0
      allow(scheduler_a).to receive(:tick) { a += 1 }
      b = 0
      allow(scheduler_b).to receive(:tick) { b += 1 }

      ticker.register scheduler_a
      ticker.register scheduler_b

      ticker.start
      100.times { break if a > 0 && b > 0; sleep 0.01 }

      a0 = a
      ticker.deregister scheduler_b
      b0 = b
      100.times { break if a > a0; sleep 0.01 }

      expect(a).to be >= 1
      expect(b).to eq b0
    end
  end
end
