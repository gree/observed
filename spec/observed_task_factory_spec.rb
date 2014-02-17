require 'spec_helper'
require 'observed/observed_task_factory'

describe Observed::ObservedTaskFactory do
  subject {
    Observed::ObservedTaskFactory.new
  }
  it 'should convert observers, translators, reporters to tasks' do
    output = mock('output')

    the_observer = Class.new(Observed::Observer) do
      def observe(data)
        data.merge(b:2)
      end
    end.new
    the_reporter = Class.new(Observed::Reporter) do
      attribute :output
      def report(tag, time, data)
        output.write(tag: tag, time: time, data: data)
      end
    end.new(output: output)
    the_translator = Class.new(Observed::Translator) do
      def translate(tag, time, data)
        data.merge(c:3)
      end
    end.new
    task = subject.convert_to_task(the_observer)
      .then(subject.convert_to_task(the_translator))
      .then(subject.convert_to_task(the_reporter))
    tag = 'the_tag'
    time = Time.now
    output.expects(:write).with(tag: tag, time: time, data: {a:1,b:2,c:3})
    task.now({a:1}, {tag: tag, time: time})
  end
end
