require 'spec_helper'
require 'observed/job'

describe Observed::MutableJob do
  let(:factory) {
    Observed::JobFactory.new(:executor => Observed::BlockingJobExecutor.new)
  }

  it 'yields the given block' do
    yielded = nil
    job = factory.mutable_job { |data|
      data
    }
    job.now({a:1}, {b:2}) do |data, options|
      yielded = [data, options]
    end
    expect(yielded).to eq([{a:1}, {b:2}])
  end

  it 'executes the job regardless of whether or not a block is given' do
    executed = nil
    job = factory.mutable_job { |data, options|
      executed = [data, options]
      data
    }
    job.now({a:1}, {b:2})
    expect(executed).to eq([{a:1}, {b:2}])
  end
end

describe Observed::ParallelJob do
  let(:factory) {
    Observed::JobFactory.new(:executor => Observed::BlockingJobExecutor.new)
  }

  it 'yields the given block' do
    job1 = factory.job { |data, |
      data.merge(c:3)
    }
    job2 = factory.job { |data|
      data.merge(d:4)
    }
    par = Observed::ParallelJob.new([job1, job2])
    yielded = []
    par.now({a:1}, {b:2}) do |data, options|
      yielded.push([data, options])
    end
    expect(yielded).to eq([[{a:1,c:3},{b:2}], [{a:1,d:4},{b:2}]])
  end

  it 'executes the job regardless of whether or not a block is given' do
    executed = []
    job1 = factory.job { |data, options|
      r = data.merge(c:3)
      executed.push([r, options])
      r
    }
    job2 = factory.job { |data, options|
      r = data.merge(d:4)
      executed.push([r, options])
      r
    }
    par = Observed::ParallelJob.new([job1, job2])
    par.now({a:1}, {b:2})
    expect(executed).to eq([[{a:1,c:3},{b:2}], [{a:1,d:4},{b:2}]])
  end
end

describe Observed::SequenceJob do
  let(:factory) {
    Observed::JobFactory.new(:executor => Observed::BlockingJobExecutor.new)
  }

  it 'yields the given block' do
    job1 = factory.job { |data|
      data.merge(c:3)
    }
    job2 = factory.job { |data|
      data.merge(d:4)
    }
    seq = Observed::SequenceJob.new(job1, job2)
    yielded = []
    seq.now({a:1}, {b:2}) do |data, options|
      yielded.push([data, options])
    end
    expect(yielded).to eq([[{a:1,c:3,d:4},{b:2}]])
  end

  it 'executes the job regardless of whether or not a block is given' do
    executed = []
    job1 = factory.job { |data, options|
      r = data.merge(c:3)
      executed.push([r, options])
      r
    }
    job2 = factory.job { |data, options|
      r = data.merge(d:4)
      executed.push([r, options])
      r
    }
    seq = Observed::SequenceJob.new(job1, job2)
    seq.now({a:1}, {b:2})
    expect(executed).to eq([[{a:1,c:3},{b:2}], [{a:1,c:3,d:4},{b:2}]])
  end
end

describe Observed::Job do
  context 'in simple use cases' do
    let(:factory) {
      Observed::JobFactory.new(:executor => Observed::BlockingJobExecutor.new)
    }
    context 'when the options as input are given' do
      it 'propagates the options from the input' do
        job1 = factory.job { |data, options|
          expect(options).to eq({b:2})
          data
        }
        job2 = factory.job { |_, options|
          expect(options).to eq({b:2})
        }
        seq = job1.then(job2)
        seq.now({a:1}, {b:2})
      end
      it 'allows to override the options from the input in subsequent jobs' do
        job1 = factory.job { |data, options|
          expect(options).to eq({b:2})
          [data, {b:3}]
        }
        job2 = factory.job { |_, options|
          expect(options).to eq({b:3})
        }
        seq = job1.then(job2)
        seq.now({a:1}, {b:2})
      end
    end
    context 'when the options as input are not given' do
      it 'provides nil in the block parameter and allows to override it in subsequent jobs' do
        job1 = factory.job { |data, options|
          expect(options).to be_nil
          [data, {b:3}]
        }
        job2 = factory.job { |_, options|
          expect(options).to eq({b:3})
        }
        seq = job1.then(job2)
        seq.now({a:1})
      end
    end
  end
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

  context 'when listeners given' do
    it 'notifies listeners with resulting data' do

      listener = mock('listener')
      factory = Observed::JobFactory.new(
          :executor => Observed::BlockingJobExecutor.new,
          :listener => listener
      )
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
      listener.expects(:on_result).with({input:1,a:2}, {opt:1})
      listener.expects(:on_result).with({input:1,a:2,b:3}, {opt:1})
      foo.now(input_data, {opt:1})
    end
  end
end
