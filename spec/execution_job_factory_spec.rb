require 'spec_helper'
require 'observed/execution_job_factory'

describe Observed::ExecutionJobFactory do
  subject {
    Observed::ExecutionJobFactory.new
  }
  it 'should convert observers, translators, reporters to jobs' do
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
    job = subject.convert_to_job(the_observer)
      .then(subject.convert_to_job(the_translator))
      .then(subject.convert_to_job(the_reporter))
    tag = 'the_tag'
    time = Time.now
    output.expects(:write).with(tag: tag, time: time, data: {a:1,b:2,c:3})
    job.now({a:1}, {tag: tag, time: time})
  end
end
