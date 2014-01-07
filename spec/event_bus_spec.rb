require 'spec_helper'

require 'observed/task'
require 'observed/event_bus'

describe Observed::EventBus do
  let(:out) {
    mock('out')
  }
  let(:factory) {
    executor = Observed::BlockingExecutor.new
    Observed::TaskFactory.new(executor: executor)
  }
  let(:the_task) {
    factory.task { |data, options|
      out.write data, options
    }
  }
  let(:bus) {
    Observed::EventBus.new(task_factory: factory)
  }
  it 'should invoke tasks when the corresponding events are emitted' do
    bus.emit('foo').now
    bus.receive(/^bar$/).then(the_task)
    bus.emit('baz').now
    out.expects(:write).with({a:1}, {b:2})
    bus.emit('bar').now({a:1}, {b:2})
    bus.emit('blah').now
  end
end
