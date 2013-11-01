require 'spec_helper'

require 'observed/builtin_plugins/average'

describe Observed::BuiltinPlugins::Average do

  before {
    load 'observed/builtin_plugins/average.rb'
  }

  subject {
    output = Observed::BuiltinPlugins::Average.new
    output.configure system: system, tag: 'foo.avg', time_window: 1.0, input_key: :num, output_key: :avg
    output
  }

  let(:system) {
    mock('system')
  }

  it 'should emit averages of inputs' do
    system.expects(:emit).with('foo.avg', {avg: 100.0})
    system.expects(:emit).with('foo.avg', {avg: 200.0})
    system.expects(:emit).with('foo.avg', {avg: 300.0})
    subject.emit('foo', Time.now, {num: '100 milliseconds'})
    subject.emit('foo', Time.now, {num: '300 milliseconds'})
    subject.emit('foo', Time.now, {num: '500 milliseconds'})
  end
end
