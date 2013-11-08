require 'spec_helper'

require 'observed/reporter'

describe Observed::Reporter do
  subject {
    described_class.new(tag_pattern: /foo/, system: sys)
  }

  let(:sys) { mock('system') }

  it 'fails when the method `match` is not overrode' do
    expect { subject.match('the_tag') }.to raise_error
  end

  it 'fails when the method `report` is not overrodo' do
    expect { subject.report('the_tag', Time.now, {test:'data'}) }.to raise_error
  end
end
