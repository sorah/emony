require 'spec_helper'
require 'emony/configuration'
require 'emony/window_scheduler'
require 'emony/window_scheduler_broker'

describe Emony::WindowSchedulerBroker do
  before do
    allow(Emony::WindowScheduler).to receive(:new) do |label, speci|
      double("window_scheduler: #{label}", label: label, spec: speci)
    end

    allow(config).to receive(:aggregation_rule_for_tag) do |label, opt|
      case label.tag
      when 'bar'
        {sub_windows: [{duration: 60, wait: 10}, {duration: 300, wait: 10}]}
      else
        raise Emony::Configuration::ConfigurationMissing
      end
    end

    allow(config).to receive(:window_specification_for_label) do |label|
      case label.tag
      when 'foo'
        {duration: 5, wait: 2, aggregators: {foo: {type: 'mock'}}}
      when 'bar'
        {duration: label.duration, wait: 10, aggregators: {foo: {type: 'mock'}}}
      else
        raise Emony::Configuration::ConfigurationMissing
      end
    end
  end

  let(:config) { double('config') }
  let(:ticker) { double('ticker', register: nil) }

  subject(:broker) { described_class.new(config, ticker) }

  describe "#get" do
    describe "(normal usage)" do
      subject(:scheduler) { broker.get('foo') }

      it "returns WindowScheduler" do
        expect(scheduler.label.to_s).to eq 'foo'
        expect(scheduler.spec).to eq(duration: 5, wait: 2, aggregators: {foo: {type: 'mock'}})
      end

      it "registers to ticker" do
        registered_scheduler = nil
        expect(ticker).to receive(:register) do |arg|
          registered_scheduler = arg
        end

        scheduler # call

        expect(registered_scheduler).to eq scheduler
      end
    end

    context "at 2nd time" do
      it "returns the same" do
        expect(broker.get('foo')).to be(broker.get('foo'))
      end
    end

    context "for different group" do
      specify do
        expect(broker.get('foo').label.to_s).to eq 'foo'
        expect(broker.get('foo:group/group').label.to_s).to eq 'foo:group/group'
        expect(broker.get('foo:group/group2').label.to_s).to eq 'foo:group/group2'
      end
    end

    context "for different duration" do
      specify do
        expect(broker.get('foo').label.to_s).to eq 'foo'
        expect(broker.get('foo@60').label.to_s).to eq 'foo@60'
        expect(broker.get('foo@300').label.to_s).to eq 'foo@300'
      end
    end
  end

  describe "#get_for_subwindows" do
    subject(:schedulers) { broker.get_for_subwindows(Emony::Label('bar')) }

    it "returns all schedulers for subwindows" do
      expect(schedulers.size).to eq 2
      expect(schedulers[0].spec[:duration]).to eq 60
      expect(schedulers[0].label.to_s).to eq 'bar@60'
      expect(schedulers[1].spec[:duration]).to eq 300
      expect(schedulers[1].label.to_s).to eq 'bar@300'
    end
  end

  describe "#on_new_window_scheduler" do
    it "accepts block and the block will be called when new WindowScheduler initialized" do
      calls = []
      broker.on_new_window_scheduler = proc do |obj|
        calls << obj
      end

      sched = broker.get('foo')
      expect(calls).to eq([sched])

      broker.get('foo')
      expect(calls).to eq([sched])
    end
  end
end
