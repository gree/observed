require 'spec_helper'
require 'observed/job'

describe Observed::Job do
  context 'when used in an immutable way' do
    it 'propagates the resulting data to next jobs' do
      factory = Observed::JobFactory.new(:executor => Observed::BlockingJobExecutor.new)
      output = mock('output')
      input_data = { input: 1 }
      a = factory.job { |data|
        data.merge(a: 2)
      }
      b = factory.job { |data, options|
        data.merge(b: 3)
      }
      c = factory.job { |data, options|
        output.write data.merge(c: 4)
      }
      d = factory.job { |data|
        output.write data.merge(d: 5)
      }
      foo = a.then(b).then(c, d)
      output.expects(:write).with({input:1,a:2,b:3,c:4})
      output.expects(:write).with({input:1,a:2,b:3,d:5})
      foo.now(input_data)
    end
  end

  context 'when used in a mutable way' do
    it 'propagates the resulting data to next jobs' do
      factory = Observed::JobFactory.new(:executor => Observed::BlockingJobExecutor.new)
      output = mock('output')
      input_data = { input: 1 }
      a = factory.mutable_job { |data|
        data.merge(a: 2)
      }
      b = factory.job { |data, options|
        data.merge(b: 3)
      }
      c = factory.job { |data, options|
        output.write data.merge(c: 4)
      }
      d = factory.job { |data|
        output.write data.merge(d: 5)
      }
      a.then(b).then(c, d)
      output.expects(:write).with({input:1,a:2,b:3,c:4})
      output.expects(:write).with({input:1,a:2,b:3,d:5})
      a.now(input_data)
    end
  end
end
