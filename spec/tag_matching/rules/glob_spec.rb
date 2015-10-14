require 'spec_helper'

require 'emony/tag_matching/rules/glob'

describe Emony::TagMatching::Rules::Glob do
  let(:pattern) { '' }
  subject(:rule) { described_class.new(pattern) }

  context "for pattern contains wildcard at tail" do
    let(:pattern) { 'a.*' }

    it { is_expected.to be_match('a.x') }
    it { is_expected.not_to be_match('a.x.y') }

    it { is_expected.not_to be_match('b.x') }
    it { is_expected.not_to be_match('b.x.y') }
  end

  context "for pattern contains recursive wildcard at tail" do
    let(:pattern) { 'a.**' }

    it { is_expected.to be_match('a.x') }
    it { is_expected.to be_match('a.x.y') }
    it { is_expected.to be_match('a.x.y.z') }

    it { is_expected.not_to be_match('b.x') }
    it { is_expected.not_to be_match('b.x.y') }
  end

  context "for pattern contains recursive wildcard at its middle" do
    let(:pattern) { 'a.**.b' }

    it { is_expected.to be_match('a.x.b') }
    it { is_expected.to be_match('a.x.y.b') }
    it { is_expected.to be_match('a.x.y.z.b') }

    it { is_expected.not_to be_match('a.b') }
    it { is_expected.not_to be_match('b.x.c') }
  end

  context "for pattern contains wildcard at its middle" do
    let(:pattern) { 'a.*.b' }

    it { is_expected.to be_match('a.x.b') }
    it { is_expected.not_to be_match('a.x.y.b') }
    it { is_expected.not_to be_match('a.x.y.z.b') }
    it { is_expected.not_to be_match('a.b') }
    it { is_expected.not_to be_match('b.x.c') }
  end

  context "for pattern contains all globbing meta characters" do
    let(:pattern) { 'a.*.b.**.c.**.*.d.**' }

    it { is_expected.to be_match('a.x0.b.x1.c.x2.x3.d.x4') }
    it { is_expected.to be_match('a.x0.b.x1.y1.c.x2.y2.x3.d.x4.y4') }

    it { is_expected.not_to be_match('o.x0.b.x1.y1.c.x2.y2.x3.d.x4.y4') }
    it { is_expected.not_to be_match('a.x0.o.x1.y1.c.x2.y2.x3.d.x4.y4') }
    it { is_expected.not_to be_match('a.x0.b.x1.y1.o.x2.y2.x3.d.x4.y4') }
    it { is_expected.not_to be_match('a.x0.b.x1.y1.c.x2.y2.x3.o.x4.y4') }

    it { is_expected.not_to be_match('a.b.x1.y1.c.x2.y2.x3.d.x4.y4') }
    it { is_expected.not_to be_match('a.x0.b.c.x2.y2.x3.d.x4.y4') }
    it { is_expected.not_to be_match('a.x0.b.x1.y1.c.x3.d.x4.y4') }
    it { is_expected.not_to be_match('a.x0.b.x1.y1.c.x2.y2.x3.d') }
  end
end
