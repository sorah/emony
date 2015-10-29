require 'timeout'
require 'spec_helper'
require 'emony/output_router'

describe Emony::OutputRouter do
  let(:window_foo) { double('window_foo', label: 'foo') }
  let(:window_bar) { double('window_bar', label: 'bar') }
  let(:output_a) { double('output_a', setup: nil, teardown: nil) }
  let(:output_b) { double('output_b', setup: nil, teardown: nil) }
  let(:output_specs) { { 'bar' => output_b, '*' => output_a } }

  subject(:router) { described_class.new(output_specs) }

  describe "lifecycle" do
    it "can start and stop" do
      Timeout.timeout(2) do
        router.start
        expect(router.running?).to eq true

        router.stop
        expect(router.running?).to eq false
      end
    end
  end

  describe "usage" do
    before do
      router.start
    end

    after do
      Timeout.timeout(2) do
        router.stop
      end
    end

    it "routes to output" do
      call = false
      expect(output_a).to receive(:put).with(window_foo)
      expect(output_b).to receive(:put).with(window_bar) do
        call = true
      end
      router.put window_foo
      router.put window_bar
      100.times { break if call; Thread.pass }
    end
  end
end
