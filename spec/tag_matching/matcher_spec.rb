require 'spec_helper'

require 'emony/tag_matching/matcher'

describe Emony::TagMatching::Matcher do
  let(:rules) { ['foo', 'a.*.foo', 'a.**', '$default'] }
  subject(:matcher) { described_class.new(rules) }

  describe "#find(tag)" do
    # TODO:

    specify { expect(matcher.find('foo')).to eq('foo') }
    specify { expect(matcher.find('a.x.foo')).to eq('a.*.foo') }
    specify { expect(matcher.find('a.b.c.foo')).to eq('a.**') }
    specify { expect(matcher.find('a.b.c')).to eq('a.**') }
    specify { expect(matcher.find('nomatch')).to eq('$default') }
  end
end
