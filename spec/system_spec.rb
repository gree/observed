require 'spec_helper'

require 'logger'

require 'observed/system'

describe Observed::System do
  subject {
    Observed::System.new(the_config)
  }

  context 'with reporters configured' do

    let(:the_config) {
      s = stub('foo')
      s.stubs(reporters: [reporter], translators: [translator])
      { config: s, logger: Logger.new(STDOUT, Logger::DEBUG), context: context }
    }

    let(:context) {
      Observed::Context.new
    }

    let(:reporter) {
      s = stub('reporter')
      s.stubs(match: true)
      s
    }

    let(:translator) {
      s = stub('translator')
      s.stubs(match: true)
      s
    }

    let(:the_time) {
      Time.now
    }

    before {
      Time.stubs(now: the_time)
    }

    context 'when the time of a report is omitted' do
      it 'complements the current time' do
        reporter.expects(:report).with('the_tag', the_time, {data:1})
        subject.report('the_tag', {data:1})
      end
    end

  end

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
