require 'spec_helper'

require 'emony/tag_parser'

describe Emony::TagParser do
  describe ".parse" do
    let(:str) { nil }
    subject(:result) { described_class.parse(str) }

    context "for simple tag" do
      let(:str) { 'foo.bar' }
      it { is_expected.to eq(tag: 'foo.bar') }
    end

    context "with duration" do
      let(:str) { 'foo.bar@60' }
      it { is_expected.to eq(tag: 'foo.bar', group: nil, group_key: nil, duration: 60) }
    end

    context "with group" do
      let(:str) { 'foo.bar:host/i-deadbeef' }
      it { is_expected.to eq(tag: 'foo.bar', group: 'host', group_key: 'i-deadbeef', duration: nil) }
    end

    context "with group and duration" do
      let(:str) { 'foo.bar@60:host/i-deadbeef' }
      it { is_expected.to eq(tag: 'foo.bar', group: 'host', group_key: 'i-deadbeef', duration: 60) }
    end

    context "with group and duration (complex)" do
      let(:str) { 'foo.bar@60:host/i-de/ad@beef' }
      it { is_expected.to eq(tag: 'foo.bar', group: 'host', group_key: 'i-de/ad@beef', duration: 60) }
    end

    context "with invalid syntax" do
      let(:str) { 'foo.bar@60:host' }
      it "raises error" do
        expect { result }.to raise_error(Emony::TagParser::ValidationError)
      end
    end
  end

  describe ".parse_tag" do
    let(:str) { nil }
    subject(:result) { described_class.parse_tag(str) }

    context "for simple tag" do
      let(:str) { 'foo.bar' }
      it { is_expected.to eq(tag: 'foo.bar') }
    end

    context "with duration" do
      let(:str) { 'foo.bar@60' }
      it "raises error" do
        expect { result }.to raise_error(Emony::TagParser::ValidationError)
      end
    end

    context "with group" do
      let(:str) { 'foo.bar:host/i-deadbeef' }
      it "raises error" do
        expect { result }.to raise_error(Emony::TagParser::ValidationError)
      end
    end

    context "with group and duration" do
      let(:str) { 'foo.bar@60:host/i-deadbeef' }
      it "raises error" do
        expect { result }.to raise_error(Emony::TagParser::ValidationError)
      end
    end
  end
end
