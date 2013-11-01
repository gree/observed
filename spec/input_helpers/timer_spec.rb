require 'spec_helper'
require 'observed/input_helpers/timer'
require 'observed/input_plugin'

describe Observed::InputHelpers::Timer do

  include Observed::SpecHelpers

  before {
    class ExampleTimerPlugin < Observed::InputPlugin
      include Observed::InputHelpers::Timer

      attribute :timeout_in_milliseconds
      attribute :time_to_sleep

      def observe
        time_and_emit(timeout_in_seconds: self.timeout_in_milliseconds / 1000.0) do
          sleep(time_to_sleep)
          time_to_sleep
        end
      end

      def self.plugin_name
        'timer'
      end
    end
  }

  subject {
    input = ExampleTimerPlugin.new
    input.configure system: system, tag: 'foo.timed', time_to_sleep: 0.001, timeout_in_milliseconds: 1000
    input
  }

  let(:system) {
    m = mock('system')
    m.stubs(:now).returns(1.0)
      .then.returns(2.0)
      .then.returns(3.0)
      .then.returns(5.0)
      .then.returns(6.0)
      .then.returns(9.0)
    m
  }

  it 'should emit results with elapsed times' do
    system.expects(:emit).with('foo.timed.success', status: :success, elapsed_time: 1.0, result: 0.001)
    system.expects(:emit).with('foo.timed.success', status: :success, elapsed_time: 2.0, result: 0.001)
    system.expects(:emit).with('foo.timed.success', status: :success, elapsed_time: 3.0, result: 0.001)
    subject.observe
    subject.observe
    subject.observe
  end
end
