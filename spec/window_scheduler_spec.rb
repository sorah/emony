require 'spec_helper'
require 'emony/window_scheduler'
require 'emony/window'
require 'emony/record'

# XXX:

describe Emony::WindowScheduler do
  let(:time) { Time.now }
  let(:window_specification) { {duration: 10, wait: 2} }
  subject(:window_scheduler) { described_class.new('label', window_specification) }

  def set_time(t)
    @time = t
  end

  before do
    set_time time
    allow(Time).to receive(:now) do
      @time
    end
  end

  describe "#add" do
    context "with record in active window period" do
      let(:record) { Emony::Record.new({time: time + 1}, time_key: :time) }

      it "adds to active window" do
        expect(window_scheduler.active).to receive(:add).with(record)

        window_scheduler.add record
      end
    end

    context "with record in waiting window period" do
      let(:record) { Emony::Record.new({time: time + 1}, time_key: :time) }

      before do
        window_scheduler.tick
        set_time time + 11
        window_scheduler.tick
      end

      it "adds to waiting window" do
        expect(window_scheduler.waiting).to receive(:add).with(record)

        window_scheduler.add record
      end

    end

    context "with record in inactive period" do
      let(:record) { Emony::Record.new({time: time + 100}, time_key: :time) }

      before do
        window_scheduler.tick
        set_time time + 11
        window_scheduler.tick
      end

      it "raises error" do
        expect {
          window_scheduler.add record
        }.to raise_error(Emony::Window::NotApplicable)
      end
    end
  end

  describe "#merge" do
    context "with window in active window period" do
      let(:window) { Emony::Window.new('label', start: time + 1, duration: 3) }

      it "merges to active window" do
        expect(window_scheduler.active).to receive(:merge).with(window)

        window_scheduler.merge window
      end
    end

    # TODO: test overlapping window

    context "with window in waiting window period" do
      let(:window) { Emony::Window.new('label', start: time + 1, duration: 3) }

      before do
        window_scheduler.tick
        set_time time + 11
        window_scheduler.tick
      end

      it "merges to waiting window" do
        expect(window_scheduler.waiting).to receive(:merge).with(window)

        window_scheduler.merge window
      end

    end

    context "with record in inactive period" do
      let(:window) { Emony::Window.new('label', start: time - 100, duration: 3) }

      before do
        window_scheduler.tick
        set_time time + 11
        window_scheduler.tick
      end

      it "raises error" do
        expect {
          window_scheduler.merge window
        }.to raise_error(Emony::Window::NotApplicable)
      end
    end
  end

  describe "#on_result" do
    it "accepts block, and block gets called with each finalized window" do
      windows = []
      window_scheduler.on_result do |window|
        windows << window
      end

      set_time time
      window_scheduler.tick
      active = window_scheduler.active
      active.add Emony::Record.new({t: active.start + 1}, time_key: :t)

      set_time time + 10 + 1
      window_scheduler.tick
      set_time time + 10 + 1 + 5
      window_scheduler.tick
      active2 = window_scheduler.active
      active2.add Emony::Record.new({t: active2.start + 1}, time_key: :t)

      expect(windows).to eq([active])

      set_time time + 30
      window_scheduler.tick

      expect(windows).to eq([active, active2])
    end

    context "when no wait time" do
      let(:window_specification) { {duration: 10, wait: 0} }

      it "accepts block, and block gets called with each finalized window" do
        windows = []
        window_scheduler.on_result do |window|
          windows << window
        end

        set_time time
        window_scheduler.tick
        active = window_scheduler.active
        active.add Emony::Record.new({t: active.start + 1}, time_key: :t)

        set_time time + 10 + 1
        window_scheduler.tick
        set_time time + 10 + 1 + 5
        window_scheduler.tick
        active2 = window_scheduler.active
        active2.add Emony::Record.new({t: active2.start + 1}, time_key: :t)

        expect(windows).to eq([active])

        set_time time + 30
        window_scheduler.tick

        expect(windows).to eq([active, active2])
      end
    end

    context "for finalized empty windows" do
      specify "passed block won't get called" do
        windows = []
        window_scheduler.on_result do |window|
          windows << window
        end

        set_time time
        window_scheduler.tick
        set_time time + 10 + 1
        window_scheduler.tick
        set_time time + 10 + 1 + 5
        window_scheduler.tick

        expect(windows).to eq([])

        set_time time + 30
        window_scheduler.tick

        expect(windows).to eq([])
      end
    end
  end

  describe "#on_no_recent_record" do
    it "accepts block, and block gets called when 2 empty windows are finalized continously" do
      calls = 0
      window_scheduler.on_no_recent_record do
        calls += 1
      end

      set_time time
      window_scheduler.tick

      set_time time + 10 + 2 + 1
      window_scheduler.tick
      expect(calls).to eq(0)

      set_time time + 10 + 2 + 10
      window_scheduler.tick
      expect(calls).to eq(0)

      set_time time + 10 + 2 + 10 + 2 + 1
      window_scheduler.tick
      expect(calls).to eq(1)

      set_time time + 10 + 2 + 10 + 2 + 10 + 2 + 1
      window_scheduler.tick
      expect(calls).to eq(2)

      window_scheduler.active.add Emony::Record.new({t: window_scheduler.active.start + 1}, time_key: :t)

      set_time time + 10 + 2 + 10 + 2 + 10 + 2 + 10 + 2 + 1
      window_scheduler.tick
      expect(calls).to eq(2)
    end
  end


  describe "#tick" do
    it "slides window as required" do
      active, waiting = window_scheduler.active, window_scheduler.waiting

      set_time time
      window_scheduler.tick
      expect(window_scheduler.active).to eq(active)
      expect(window_scheduler.waiting).to be_nil

      set_time time + 2
      window_scheduler.tick
      expect(window_scheduler.active).to eq(active)
      expect(window_scheduler.waiting).to be_nil

      set_time time + 10 + 1
      window_scheduler.tick
      expect(window_scheduler.waiting).to eq(active)
      expect(window_scheduler.active).not_to eq(active)
      expect(window_scheduler.active).to be_a(Emony::Window)
      active, waiting = window_scheduler.active, window_scheduler.waiting

      set_time time + 10 + 2 + 1
      window_scheduler.tick
      expect(window_scheduler.waiting).to be_nil
      expect(window_scheduler.active).to eq(active)

      set_time time + 10 + 2 + 10
      window_scheduler.tick
      expect(window_scheduler.waiting).to eq(active)
      expect(window_scheduler.active).not_to eq(active)
      expect(window_scheduler.active).to be_a(Emony::Window)
      active, waiting = window_scheduler.active, window_scheduler.waiting
    end

    context "when no wait time" do
      let(:window_specification) { {duration: 10, wait: 0} }

      it "slides window as required" do
        active = window_scheduler.active

        set_time time
        window_scheduler.tick
        expect(window_scheduler.active).to eq(active)
        expect(window_scheduler.waiting).to be_nil

        set_time time + 2
        window_scheduler.tick
        expect(window_scheduler.active).to eq(active)
        expect(window_scheduler.waiting).to be_nil

        set_time time + 10 + 1
        window_scheduler.tick
        expect(window_scheduler.waiting).to be_nil
        expect(window_scheduler.active).not_to eq(active)
        expect(window_scheduler.active).to be_a(Emony::Window)
        active = window_scheduler.active

        set_time time + 10 + 2 + 1
        window_scheduler.tick
        expect(window_scheduler.waiting).to be_nil
        expect(window_scheduler.active).to eq(active)

        set_time time + 10 + 2 + 10
        window_scheduler.tick
        expect(window_scheduler.waiting).to be_nil
        expect(window_scheduler.active).not_to eq(active)
        expect(window_scheduler.active).to be_a(Emony::Window)
        active, waiting = window_scheduler.active, window_scheduler.waiting
      end
    end
  end
end
