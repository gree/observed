require 'spec_helper'

require 'observed/reader'

describe Observed::Reader do
  subject {
    described_class.new
  }

  context 'when the method `read` is not overrode' do
    it 'fails' do
      expect { subject.read }.to raise_error
    end
  end
end
