require 'spec_helper'
require 'emony/aggregators'
require 'emony/finalized_window'
require 'emony/window'

describe Emony::Window do
  let(:aggregator_a) { double('aggregator_a', state: :state_a, result: :result_a) }
  let(:aggregator_b) { double('aggregator_b', state: :state_b, result: :result_b) }

  let(:start_time) { Time.at(Time.now.to_i) } # XXX:

  subject(:window) { described_class.new('label', start: start_time, duration: 10, wait: 2, aggregators: {a: aggregator_a, b: aggregator_b}) }

  describe "#aggregators" do
    context "when initialied with Hash values" do
      before do
        allow(Emony::Aggregators).to receive(:find).with('agg').and_return(aggregator_class)
      end

      let(:aggregator_class) do
        Class.new do
          def initialize(*args)
            @args = args
          end

          attr_reader :args
        end
      end
      let(:aggregator_a) { {type: 'agg', option: 1} }

      it "finds aggregator class and instantiate that" do
        expect(window.aggregators[:a]).to be_a(aggregator_class)
        expect(window.aggregators[:a].args).to eq([{type: 'agg', option: 1}])
      end
    end
  end

  describe "#id" do
    subject { window.id }
    # TODO:
    it { is_expected.to be_a(String) }
  end

  describe "#finish" do
    subject { window.finish }
    it { is_expected.to eq(start_time + 10) }
  end

  describe "#deadline" do
    subject { window.deadline }
    it { is_expected.to eq(start_time + 12) }
  end

  describe "#state" do
    subject { window.state }
    it { is_expected.to eq(a: :state_a, b: :state_b) }

    context "after finalized" do
      before do
        allow(Time).to receive(:now).and_return(start_time + 15)
      end

      it { is_expected.to eq(a: :state_a, b: :state_b) }
    end
  end

  describe "#result" do
    subject { window.result }
    it { is_expected.to eq(a: :result_a, b: :result_b) }

    context "after finalized" do
      before do
        allow(Time).to receive(:now).and_return(start_time + 15)
      end

      it { is_expected.to eq(a: :result_a, b: :result_b) }
    end
  end

  describe "#finalized?" do
    subject { window.finalized? }

    it { is_expected.to eq false }

    context "when finalized" do
      before do
        allow(Time).to receive(:now).and_return(start_time + 15)
      end

      it { is_expected.to eq true }
    end
  end

  describe "#finalized_window" do
    subject { window.finalized_window }

    context "when not finalized" do
      before do
        allow(Time).to receive(:now).and_return(start_time + 1)
      end

      it { is_expected.to eq nil }
    end

    context "when finalized" do
      before do
        allow(Time).to receive(:now).and_return(start_time + 15)
      end

      it 'returns Emony::FinalizedWindow' do
        expect(subject).to be_a(Emony::FinalizedWindow)
        expect(subject.id).to eq window.id
        expect(subject.start).to eq window.start
        expect(subject.finish).to eq window.finish
        expect(subject.duration).to eq window.duration
        expect(subject.state).to eq window.state
        expect(subject.result).to eq window.result
      end
    end
  end

  describe "#applicable_time?" do
    subject { window.applicable_time?(time) }

    context "with time before the window starts" do
      let(:time) { start_time - 10 }
      it { is_expected.to eq false }
    end

    context "with time when the window starts" do
      let(:time) { start_time }
      it { is_expected.to eq true }
    end

    context "with time during the window opens" do
      let(:time) { start_time + 5 }
      it { is_expected.to eq true }
    end

    context "with time after the window ends" do
      let(:time) { start_time + 11 }
      it { is_expected.to eq false }
    end

    context "with time after the deadline" do
      let(:time) { start_time + 30 }
      it { is_expected.to eq false }
    end
  end

  describe "#applicable?" do
    # TODO:
  end

  describe "#gap_with_window" do
    subject(:window) { described_class.new('label', start: start_time, duration: 3, wait: 0) }

    # dbca012345
    # ---  4
    #   ---  2
    #     -  0
    #     ===
    #      -  0
    #      ---  1
    #         ---  4
    #    -----  -2

    specify { expect(window.gap_with_window(double('window', start: start_time - 4, finish: start_time - 1))).to eq 4 }
    specify { expect(window.gap_with_window(double('window', start: start_time - 2, finish: start_time + 1))).to eq 2 }
    specify { expect(window.gap_with_window(double('window', start: start_time + 0, finish: start_time + 1))).to eq 0 }
    specify { expect(window.gap_with_window(double('window', start: start_time + 1, finish: start_time + 2))).to eq 0 }
    specify { expect(window.gap_with_window(double('window', start: start_time + 1, finish: start_time + 4))).to eq 1 }
    specify { expect(window.gap_with_window(double('window', start: start_time + 4, finish: start_time + 7))).to eq 4 }
    specify { expect(window.gap_with_window(double('window', start: start_time - 1, finish: start_time + 4))).to eq -2 }
  end

  describe "#add" do
    context "with record at applicable time" do
      let(:record) { double('record', time: start_time + 2) }

      it "adds passed record to its aggregators" do
        expect(aggregator_a).to receive(:add).with(record)
        expect(aggregator_b).to receive(:add).with(record)

        window.add record
      end
    end

    context "with record at not applicable time" do
      let(:record) { double('record', imported_time: Time.now, time: start_time - 10) }

      it "raises NotApplicable error" do
        expect {
          window.add record
        }.to raise_error(Emony::Window::NotApplicable)
      end
    end

    context "after deadline" do
      let(:record) { double('record', imported_time: Time.now, time: start_time + 2) }

      before do
        allow(Time).to receive(:now).and_return(start_time + 15)
      end

      it "raises Finalized error" do
        expect {
          window.add record
        }.to raise_error(Emony::Window::Finalized)
      end
    end
  end

  describe "#merge" do
    let(:aggregator_a2) { double('aggregator_a2', state: :state_a2, result: :result_a2) }
    let(:aggregator_b2) { double('aggregator_b2', state: :state_b2, result: :result_b2) }

    context "with window at same time" do
      let(:another_window) { double('window', start: start_time, finish: start_time + 10, state: {a: aggregator_a2.state, b: aggregator_b2.state}, result: {a: aggregator_a2.result, b: aggregator_b2.result}) }

      it "merges passed window's state to its aggregators" do
        expect(aggregator_a).to receive(:merge).with(:state_a2)
        expect(aggregator_b).to receive(:merge).with(:state_b2)

        window.merge another_window
      end
    end

    context "with window during itself" do
      let(:another_window) { double('window', start: start_time + 2, finish: start_time + 5, state: {a: aggregator_a2.state, b: aggregator_b2.state}, result: {a: aggregator_a2.result, b: aggregator_b2.result}) }

      it "merges passed window's state to its aggregators" do
        expect(aggregator_a).to receive(:merge).with(:state_a2)
        expect(aggregator_b).to receive(:merge).with(:state_b2)

        window.merge another_window
      end
    end

    context "with window at not appliciable time (starts before)" do
      let(:another_window) { double('window', start: start_time - 100, finish: start_time + 10, state: {a: aggregator_a2.state, b: aggregator_b2.state}, result: {a: aggregator_a2.result, b: aggregator_b2.result}) }

      it "raises NotApplicable error" do
        expect {
        window.merge another_window
        }.to raise_error(Emony::Window::NotApplicable)
      end
    end

    context "with window at not appliciable time (finish over)" do
      let(:another_window) { double('window', start: start_time, finish: start_time + 10 - 100 , state: {a: aggregator_a2.state, b: aggregator_b2.state}, result: {a: aggregator_a2.result, b: aggregator_b2.result}) }

      it "raises NotApplicable error" do
        expect {
          window.merge another_window
        }.to raise_error(Emony::Window::NotApplicable)
      end
    end

    context "with window at not appliciable time" do
      let(:another_window) { double('window', start: start_time - 100, finish: start_time + 10 - 100 , state: {a: aggregator_a2.state, b: aggregator_b2.state}, result: {a: aggregator_a2.result, b: aggregator_b2.result}) }

      it "raises NotApplicable error" do
        expect {
          window.merge another_window
        }.to raise_error(Emony::Window::NotApplicable)
      end
    end

    context "after deadline" do
      let(:another_window) { double('window', start: start_time, finish: start_time + 10, state: {a: aggregator_a2.state, b: aggregator_b2.state}, result: {a: aggregator_a2.result, b: aggregator_b2.result}) }

      before do
        allow(Time).to receive(:now).and_return(start_time + 15)
      end

      it "raises Finalized error" do
        expect {
          window.merge another_window
        }.to raise_error(Emony::Window::Finalized)
      end
    end
  end
end
