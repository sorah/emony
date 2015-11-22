require 'spec_helper'
require 'emony/record'

describe Emony::Record do
  describe "time determining:" do
    let(:t) { Time.now - 10 }
    let(:options) { {} }
    subject(:record) { described_class.new({time: t}, **options) }
    subject(:record_time) { record.time }

    describe "source:" do
      context "when nothing given" do
        before do
          allow(Time).to receive(:now).and_return(t-1)
        end

        it "uses Time.now" do
          expect(record_time).to eq(t-1)
        end
      end

      context "when time_key given" do
        let(:options) { {time_key: :time} }

        it "uses from given key" do
          expect(record_time).to eq(t)
        end
      end

      context "when config given" do
        let(:config) do
          double('config').tap do |c|
            allow(c).to receive(:aggregation_rule_for_tag).with('x').and_return(time: :time)
          end
        end

        let(:options) { {config: config, tag: 'x'} }

        it "uses from determined key" do
          expect(record_time).to eq(t)
        end
      end

      context "when config given but no key for tag" do
        before do
          allow(Time).to receive(:now).and_return(t-1)
        end

        let(:config) do
          double('config').tap do |c|
            allow(c).to receive(:aggregation_rule_for_tag).with('x').and_return(nil)
          end
        end

        let(:options) { {config: config, tag: 'x'} }

        it "uses Time.now" do
          expect(record_time).to eq(t-1)
        end
      end


      context "when both time_key and config given" do
        let(:config) do
          double('config') # no mock, it shouldn't receive anything
        end

        let(:options) { {time_key: :time, config: config, tag: 'x'} }

        it "uses from time_key" do
          expect(record_time).to eq(t)
        end
      end

      context "when both time_key and time given" do
        let(:options) { {time_key: :time, time: t+1} }

        it "uses from time" do
          expect(record_time).to eq(t+1)
        end

      end

      context "when both config and time given" do
        let(:config) do
          double('config') # no mock, it shouldn't receive anything
        end

        let(:options) { {time: t+1, config: config, tag: 'x'} }

        it "uses from time" do
          expect(record_time).to eq(t+1)
        end
      end
    end

    describe "parsing:" do
      let(:options) { {time_key: :time} }

      context "when Time" do
        let(:t0) { Time.now }
        let(:t) { t0-100 }
        it { is_expected.to eq(t0-100) }
      end
      context "when String" do
        let(:t0) { (Time.now-100) }
        let(:t) { t0.to_s }
        it { is_expected.to eq(Time.parse(t)) }
      end
    end
  end
end
