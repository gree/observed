require 'spec_helper'

require 'observed/builtin_plugins/average'

describe Observed::BuiltinPlugins::Average do

  subject {
    output = Observed::BuiltinPlugins::Average.new
    output.configure system: system, tag: 'foo.avg', time_window: 1.0
    output
  }

  before {
    load 'observed/builtin_plugins/average.rb'
  }

  let(:system) {
    mock('system')
  }

  it 'should emit averages of inputs' do
    system.expects(:emit).with('foo.avg', anything, '100.0')
    system.expects(:emit).with('foo.avg', anything, '200.0')
    system.expects(:emit).with('foo.avg', anything, '300.0')
    subject.emit('foo', Time.now, '100 milliseconds')
    subject.emit('foo', Time.now, '300 milliseconds')
    subject.emit('foo', Time.now, '500 milliseconds')
  end
end
