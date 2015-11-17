require 'spec_helper'

require 'emony/record'

require 'emony/filter_chain'

describe Emony::FilterChain do
  let(:filter) do
    double('filter').tap do |f|
      allow(f).to receive(:filter) do |i|
        Emony::Record.new({n: i[:n].succ})
      end
    end
  end

  let(:record) { Emony::Record.new({n: 1}) }

  let(:filters) { [filter] }

  subject(:chain) { described_class.new(filters) }

  describe "#filter" do
    subject(:filtered_record) { chain.filter(record) }

    context "with one filter" do
      it { is_expected.to be_a(Emony::Record) }
      specify { expect(filtered_record[:n]).to eq 2 }
    end

    context "with two filters" do
      let(:filters) { [filter, filter] }

      it { is_expected.to be_a(Emony::Record) }
      specify { expect(filtered_record[:n]).to eq 3 }
    end

  end
end

