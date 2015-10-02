require 'spec_helper'
require 'emony/record'
require 'emony/aggregators/standard'

describe Emony::Aggregators::Standard do
  subject(:aggregator) { described_class.new(key: :n) }

  it "calculates min/max/avg" do
    aggregator.add Emony::Record.new(n: 12)
    aggregator.add Emony::Record.new(n: 18)
    aggregator.add Emony::Record.new(n: 9)

    expect(aggregator.result[:average]).to eq 13
    expect(aggregator.result[:max]).to eq 18
    expect(aggregator.result[:min]).to eq 9
    expect(aggregator.result[:count]).to eq 3
    expect(aggregator.result[:total]).to eq 39
  end

  it "can accept merge" do
    a = described_class.new(key: :n)
    a.add Emony::Record.new(n: 12)
    a.add Emony::Record.new(n: 18)
    a.add Emony::Record.new(n: 9)

    aggregator.add Emony::Record.new(n: 24)
    aggregator.add Emony::Record.new(n: 3)
    aggregator.add Emony::Record.new(n: 6)
    aggregator.merge a.state

    expect(aggregator.result[:average]).to eq 12
    expect(aggregator.result[:max]).to eq 24
    expect(aggregator.result[:min]).to eq 3
    expect(aggregator.result[:count]).to eq 6
    expect(aggregator.result[:total]).to eq 72
  end
end
