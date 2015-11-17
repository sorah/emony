require 'spec_helper'

require 'emony/record'

require 'emony/filters/numeric'

describe Emony::Filters::Numeric do
  let(:n) { 1 }
  let(:record) { Emony::Record.new({n: n}) }

  let(:options) { {key: :n} }
  subject(:filter) { described_class.new(options) }
  subject(:filtered_record) { filter.filter(record) }
  subject(:result) { filtered_record[:n] }

  describe "simple usage:" do
    context "when input is Fixnum" do
      let(:n) { 1 }
      it { is_expected.to eq(1) }
    end

    context "when input is Float" do
      let(:n) { 3.14 }
      it { is_expected.to eq(3.14) }
    end

    context "when input is String" do
      let(:n) { "1" }
      it { is_expected.to eq(1) }
    end

    context "when input is String (float)" do
      let(:n) { "3.14" }
      it { is_expected.to eq(3) }
    end
  end

  describe "skip_nil option" do
    context "with false:" do
      let(:options) { {key: :n, skip_nil: false} }

      context "when input is nil" do
        let(:n) { nil }
        it "raises error" do
          expect {
            filtered_record
          }.to raise_error(ArgumentError)
        end
      end

      context "when input is not nil" do
        let(:n) { 42 }
        it "raises error" do
          expect {
            filtered_record
          }.not_to raise_error
        end
      end
    end
  end

  describe "float option" do
    context "with nil:" do
      let(:options) { {key: :n, float: nil} }
      context "when input is Fixnum" do
        let(:n) { 3 }
        it { is_expected.to eq(3.0) }
      end

      context "when input is Float" do
        let(:n) { 3 }
        it { is_expected.to eq(3.0) }
      end

      context "when input is String" do
        let(:n) { "3.14" }
        it { is_expected.to eq(3) }
      end
    end

    context "with false:" do
      let(:options) { {key: :n, float: false} }

      context "when input is Fixnum" do
        let(:n) { 3 }
        it { is_expected.to eq(3) }
      end

      context "when input is Float" do
        let(:n) { 3 }
        it { is_expected.to eq(3) }
      end

      context "when input is String" do
        let(:n) { "3.14" }
        it { is_expected.to eq(3) }
      end
    end

    context "with true:" do
      let(:options) { {key: :n, float: true} }

      context "when input is Fixnum" do
        let(:n) { 3 }
        it { is_expected.to eq(3.0) }
      end

      context "when input is Float" do
        let(:n) { 3 }
        it { is_expected.to eq(3.0) }
      end

      context "when input is String" do
        let(:n) { "3.14" }
        it { is_expected.to eq(3.14) }
      end
    end
  end

  describe "result_in_float option:" do
    context "with true:" do
      let(:options) { {key: :n, result_in_float: true} }

      context "when input is Fixnum" do
        let(:n) { 3 }
        it { is_expected.to eq(3.0) }
      end

      context "when input is Float" do
        let(:n) { 3.14 }
        it { is_expected.to eq(3.14) }
      end

      context "when input is String" do
        let(:n) { "3.14" }
        it { is_expected.to eq(3.0) }
      end
    end

    context "with false:" do
      let(:options) { {key: :n, result_in_float: false} }

      context "when input is Fixnum" do
        let(:n) { 3 }
        it { is_expected.to eq(3) }
      end

      context "when input is Float" do
        let(:n) { 3.14 }
        it { is_expected.to eq(3) }
      end

      context "when input is String" do
        let(:n) { "3.14" }
        it { is_expected.to eq(3) }
      end
    end
  end

  describe "implicit_float" do
    context "when no float option, but result_in_float is false:" do
      let(:options) { {key: :n, result_in_float: false, op: [add: 1.5]} }

      context "when input is Fixnum" do
        let(:n) { 1 }
        it { is_expected.to eq(2) }
      end

      context "when input is Float" do
        let(:n) { 1.0 }
        it { is_expected.to eq(2) }
      end

      context "when input is String" do
        let(:n) { "1.0" }
        it { is_expected.to eq(2) }
      end
    end

    context "when no float option and result_in_float option:" do
      let(:options) { {key: :n, result_in_float: false, op: [add: 1.5]} }

      context "when input is Fixnum" do
        let(:n) { 1 }
        it { is_expected.to eq(2) }
      end

      context "when input is Float" do
        let(:n) { 1.0 }
        it { is_expected.to eq(2) }
      end

      context "when input is String" do
        let(:n) { "1.0" }
        it { is_expected.to eq(2) }
      end
    end

    context "when no float option, and result_in_float is false:" do
      let(:options) { {key: :n, result_in_float: false, op: [add: 1.5]} }

      context "when input is Fixnum" do
        let(:n) { 1 }
        it { is_expected.to eq(2) }
      end

      context "when input is Float" do
        let(:n) { 1.0 }
        it { is_expected.to eq(2) }
      end

      context "when input is String" do
        let(:n) { "1.0" }
        it { is_expected.to eq(2) }
      end
    end

    context "when no float option, and result_in_float is false:" do
      let(:options) { {key: :n, result_in_float: false, op: [add: 1.5]} }

      context "when input is Fixnum" do
        let(:n) { 1 }
        it { is_expected.to eq(2) }
      end

      context "when input is Float" do
        let(:n) { 1.0 }
        it { is_expected.to eq(2) }
      end

      context "when input is String" do
        let(:n) { "1.0" }
        it { is_expected.to eq(2) }
      end
    end
  end

  describe "op:" do
    let(:op) { nil }
    let(:options) { {key: :n, op: op} }

    describe "add:" do
      let(:n) { 10 }
      let(:op) { [add: 20] }

      it { is_expected.to eq 30 }
    end

    describe "subtract:" do
      let(:n) { 30 }
      let(:op) { [subtract: 20] }

      it { is_expected.to eq 10 }
    end

    describe "multiply:" do
      let(:n) { 30 }
      let(:op) { [multiply: 3] }

      it { is_expected.to eq 90 }
    end

    describe "divide:" do
      let(:n) { 30 }
      let(:op) { [divide: 3] }

      it { is_expected.to eq 10 }
    end

    describe "multiple ops:" do
      let(:n) { 30 }
      let(:op) { [{subtract: 9}, {multiply: 2}] }
      it { is_expected.to eq 42 }
    end
  end
end
