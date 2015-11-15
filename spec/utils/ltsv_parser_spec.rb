require 'spec_helper'

require 'emony/utils/ltsv_parser'

describe Emony::Utils::LtsvParser do
  describe ".parse" do
    let(:string) { "" }
    subject(:result) { described_class.parse(string) }

    describe "with normal usage" do
      let(:string) { "a:1\tb:2\tc:3" }
      it { is_expected.to eq('a' => '1', 'b' => '2', 'c' => '3') }
    end

    describe "with including invalid part" do
      let(:string) { "a:1\tb2\tc:3" }
      it { is_expected.to eq('a' => '1', 'c' => '3') }
    end

    describe "with \\n at tail" do
      let(:string) { "a:1\tb2\tc:3\n" }
      it { is_expected.to eq('a' => '1', 'c' => '3') }
    end
  end
end
