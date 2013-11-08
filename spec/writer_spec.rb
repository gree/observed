require 'spec_helper'

require 'observed/writer'

describe Observed::Writer do

  subject {
    described_class.new
  }

  context 'when the method `write(tag, time, data)` is not overrode' do
    it 'fails' do
      expect { subject.write('the_tag', Time.now, {test:{data:1}}) }.to raise_error
    end
  end
end
