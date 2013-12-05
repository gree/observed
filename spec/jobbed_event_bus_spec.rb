require 'spec_helper'

require 'observed/job'
require 'observed/jobbed_event_bus'

describe Observed::JobbedEventBus do
  let(:out) {
    mock('out')
  }
  let(:factory) {
    executor = Observed::BlockingJobExecutor.new
    Observed::JobFactory.new(executor: executor)
  }
  let(:the_job) {
    factory.job { |data, options|
      out.write data, options
    }
  }
  let(:bus) {
    Observed::JobbedEventBus.new(job_factory: factory)
  }
  it 'should invoke jobs when the corresponding events are emitted' do
    bus.emit('foo')
    bus.receive(/^bar$/).then(the_job)
    bus.emit('baz')
    out.expects(:write).with({a:1}, {b:2})
    bus.emit('bar', {a:1}, {b:2})
    bus.emit('blah')
  end
  it 'should return the job to emit events' do
    bus.pipe_to_emit('foo').now
    bus.receive(/^bar$/).then(the_job)
    bus.pipe_to_emit('baz').now
    out.expects(:write).with({a:1}, {b:2})
    bus.pipe_to_emit('bar').now({a:1}, {b:2})
    bus.pipe_to_emit('blah').now
  end
end
