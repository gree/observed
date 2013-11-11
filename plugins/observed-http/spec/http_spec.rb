require 'spec_helper'

require 'observed/http'

describe Observed::Plugins::HTTP do

  subject {
    Observed::Plugins::HTTP.new
  }

  before {
    subject.configure config
  }

  let(:config) {
    {
        timeout_in_milliseconds: 1000,
        method: 'get',
        url: 'http://google.com/',
        tag: 'test',
        system: sys
    }
  }

  let(:sys) {
    sys = mock('system')
    sys.stubs(:now).returns(before).then.returns(after)
    sys
  }

  let(:before) {
    Time.now
  }

  let(:after) {
    Time.now + 1
  }

  let(:response) {
    res = stub('response')
    res.stubs(body: 'the response body')
    res
  }

  context 'when timed out' do
    before {
      Timeout.expects(:timeout).raises(Timeout::Error)

      sys.expects(:report).with('test.error', {status: :error, error: {message: ''}, timed_out: true})
    }

    it 'reports an error' do
      expect { subject.observe }.to_not raise_error
    end
  end

  context 'when not timed out' do
    before {
      Timeout.expects(:timeout).returns({ status: :success, result: 'Get http://google.com/' })

      sys.expects(:report).with('test.success', {status: :success, result: 'Get http://google.com/', elapsed_time: after - before})
    }

    it 'reports an success' do
      expect { subject.observe }.to_not raise_error
    end
  end

end
