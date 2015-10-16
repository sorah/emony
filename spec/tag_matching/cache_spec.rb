require 'spec_helper'
require 'emony/tag_matching/cache'

describe Emony::TagMatching::Cache do
  subject(:cache) { described_class.new(3) }

  it "drops old keys" do
    cache.set(:a, 1)
    cache.set(:b, 2)
    cache.set(:c, 3)

    expect(cache.get(:a)).to eq 1
    expect(cache.get(:b)).to eq 2
    expect(cache.get(:c)).to eq 3

    cache.set(:d, 4)

    expect(cache.get(:a)).to be_nil
    expect(cache.get(:b)).to eq 2
    expect(cache.get(:c)).to eq 3
    expect(cache.get(:d)).to eq 4
  end

  describe "#fetch(key)" do
    it "returns from cache if key exists" do
      cache.set(:a, 1)
      expect(cache.fetch(:a) { 2 }).to eq 1
    end

    it "calls block and store its result if key doesn't exist" do
      expect(cache.get(:a)).to be_nil
      expect(cache.fetch(:a) { 1 }).to eq 1
      expect(cache.get(:a)).to eq 1
    end
  end
end
