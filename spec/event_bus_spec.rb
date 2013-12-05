require 'spec_helper'
require 'observed/event_bus'

describe Observed::EventBus do
  it 'calls the handler for the emitted event' do
    handler_one_called = false
    handler_two_called = false
    bus = Observed::EventBus.new
    expect { bus.emit('foo') }.to_not raise_error
    expect { bus.on_receive(/^bar$/) { handler_one_called = true } }.to_not raise_error
    expect { bus.on_receive(/^baz$/) { handler_two_called = true } }.to_not raise_error
    expect { bus.emit('bar') }.to_not raise_error
    expect(handler_one_called).to be_true
    expect(handler_two_called).to be_false
  end
end
