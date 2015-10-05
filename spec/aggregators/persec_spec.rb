require 'spec_helper'
require 'emony/record'
require 'emony/aggregators/persec'

describe Emony::Aggregators::Persec do
  it "can aggregate" do
    agg = described_class.new
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 0)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 0)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 0)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 1)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 1)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 2)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 2)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 5)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 5)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 5)}, time_key: :time)

    expect(agg.result[:duration]).to eq 5.0
    expect(agg.result[:persec]).to eq 2.0
  end

  it "can merge" do
    agg = described_class.new
   agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 1)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 1)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 2)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 2)}, time_key: :time)
    agg.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 5)}, time_key: :time)
    agg2 = described_class.new
    agg2.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 0)}, time_key: :time)
    agg2.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 0)}, time_key: :time)
    agg2.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 0)}, time_key: :time)
    agg2.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 5)}, time_key: :time)
    agg2.add Emony::Record.new({time: Time.local(2015, 10, 5, 20, 4, 5)}, time_key: :time)

    agg.merge agg2.state

    expect(agg.result[:duration]).to eq 5.0
    expect(agg.result[:persec]).to eq 2.0
  end
end
