require 'spec_helper'
require 'observed/hash/builder'

describe Observed::Hash::Builder do

  subject {
    described_class.new(hash)
  }

  context 'with a source hash' do

    let(:hash) { {} }

    context 'with a key path' do
      it 'decodes the key path and recursively creates missing Hash object for each part in the key path' do
        subject['foo.bar'] = 1

        expect(subject.build).to eq({foo:{bar:1}})
      end
    end

    context 'with a regular string key' do
      it 'updates the value for the key' do
        subject['foo'] = 1
        expect(subject.build).to eq({foo:1})
      end
    end

    context 'with a regular symbol key' do
      it 'updates the value for the key' do
        subject[:foo] = 1
        expect(subject.build).to eq({foo:1})
      end
    end
  end
end
