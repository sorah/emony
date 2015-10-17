require 'spec_helper'

require 'emony/label'

describe Emony::Label do
  describe "#to_s" do
    let(:label) { nil }
    subject(:string) { label.to_s }

    context "for tag-only label" do
      let(:label) { described_class.new(tag: 'foo.bar') }
      it { is_expected.to eq 'foo.bar' }
    end

    context "for tag and duration" do
      let(:label) { described_class.new(tag: 'foo.bar', duration: 60) }
      it { is_expected.to eq 'foo.bar@60' }
    end

    context "for tag and duration and group" do
      let(:label) { described_class.new(tag: 'foo.bar', duration: 60, group: 'host', group_key: 'i-deadbeef') }
      it { is_expected.to eq 'foo.bar@60:host/i-deadbeef' }
    end

    context "for tag and group" do
      let(:label) { described_class.new(tag: 'foo.bar', group: 'host', group_key: 'i-deadbeef') }
      it { is_expected.to eq 'foo.bar:host/i-deadbeef' }
    end
  end
end
