require 'spec_helper'

require 'logger'

require 'observed/system'

describe Observed::System do
  subject {
    Observed::System.new(the_config)
  }

  context 'with observers configured' do

    let(:observers) {
      [observer]
    }

    let(:observer) {
      c = stub('observer')
      c.stubs(tag: 'bar')
      c
    }

    let(:context) {
      Observed::Context.new
    }

    let(:the_config) {
      c = stub('config')
      c.stubs(observers: observers)
      c
      { config: c, logger: Logger.new(STDOUT, Logger::DEBUG), context: context }
    }

    context 'when there is no matching observer for a tag' do
      it 'fails to run' do
        expect { subject.run('foo') }.to raise_error(/No configuration found for observation name 'foo'/)
      end
    end
  end
end
