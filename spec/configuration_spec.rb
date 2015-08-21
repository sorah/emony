require 'spec_helper'
require 'emony/configuration'

describe Emony::Configuration do
  it "symbolize keys" do
    config = described_class.new(
      'a' => {'b' => {'c' => ['d' => ['e', 'f' => 'g']]}},
    )

    expect(config[:a][:b][:c][0][:d][1][:f]).to eq 'g'
  end
end
