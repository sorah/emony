require 'spec_helper'
require 'emony/label'
require 'emony/configuration'

describe Emony::Configuration do
  it "symbolize keys" do
    config = described_class.new(
      'a' => {'b' => {'c' => ['d' => ['e', 'f' => 'g']]}},
    )

    expect(config[:a][:b][:c][0][:d][1][:f]).to eq 'g'
  end

  describe "#window_specification_for_label" do
    subject(:config) do
      described_class.new(
        aggregations: {
          foo: rule
        }
      )
    end

    let(:rule) do
      {
        items: {foo: {type: 'mock', option: 1}},
        window: {duration: 10, wait: 2},
        sub_windows: [{duration: 60, wait: 10}, {duration: 300, wait: 20}, {duration: 3600, wait: 120}],
      }
    end

    let(:label) { nil }

    subject(:specification) { config.window_specification_for_label(Emony::Label(label)) }

    context "for main window" do
      let(:label) { 'foo' }
      it { is_expected.to eq(duration: 10, wait: 2, aggregators: {foo: {type: 'mock', option: 1}}) }
    end

    context "for sub window" do
      let(:label) { 'foo@300' }
      it { is_expected.to eq(duration: 300, wait: 20, aggregators: {foo: {type: 'mock', option: 1}}) }
    end
  end
end
