require 'spec_helper'

require 'observed/hash/fetcher'

describe Observed::Hash::Fetcher do

  subject {
    described_class.new(hash)
  }

  context 'when the source hash is nil' do

    let(:hash) { nil }

    it 'fails' do
      expect { subject }.to raise_error
    end
  end

  context 'when the source hash is nested' do

    let(:hash) { {foo:{bar:1},baz:2} }

    it 'decodes the key path to recursively find the value' do
      expect(subject['foo.bar']).to eq(1)
      expect(subject['baz']).to eq(2)
    end
  end
end
