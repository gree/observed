require 'spec_helper'
require 'observed/task'

describe Observed::MutableTask do
  let(:factory) {
    Observed::TaskFactory.new(:executor => Observed::BlockingExecutor.new)
  }

  it 'yields the given block' do
    yielded = nil
    task = factory.mutable_task { |data|
      data
    }
    task.now({a:1}, {b:2}) do |data, options|
      yielded = [data, options]
    end
    expect(yielded).to eq([{a:1}, {b:2}])
  end

  it 'executes the task regardless of whether or not a block is given' do
    executed = nil
    task = factory.mutable_task { |data, options|
      executed = [data, options]
      data
    }
    task.now({a:1}, {b:2})
    expect(executed).to eq([{a:1}, {b:2}])
  end
end

describe Observed::ParallelTask do
  let(:factory) {
    Observed::TaskFactory.new(:executor => Observed::BlockingExecutor.new)
  }

  it 'yields the given block' do
    task1 = factory.task { |data, |
      data.merge(c:3)
    }
    task2 = factory.task { |data|
      data.merge(d:4)
    }
    par = Observed::ParallelTask.new([task1, task2])
    yielded = []
    par.now({a:1}, {b:2}) do |data, options|
      yielded.push([data, options])
    end
    expect(yielded).to eq([[{a:1,c:3},{b:2}], [{a:1,d:4},{b:2}]])
  end

  it 'executes the task regardless of whether or not a block is given' do
    executed = []
    task1 = factory.task { |data, options|
      r = data.merge(c:3)
      executed.push([r, options])
      r
    }
    task2 = factory.task { |data, options|
      r = data.merge(d:4)
      executed.push([r, options])
      r
    }
    par = Observed::ParallelTask.new([task1, task2])
    par.now({a:1}, {b:2})
    expect(executed).to eq([[{a:1,c:3},{b:2}], [{a:1,d:4},{b:2}]])
  end
end

describe Observed::SequenceTask do
  let(:factory) {
    Observed::TaskFactory.new(:executor => Observed::BlockingExecutor.new)
  }

  it 'yields the given block' do
    task1 = factory.task { |data|
      data.merge(c:3)
    }
    task2 = factory.task { |data|
      data.merge(d:4)
    }
    seq = Observed::SequenceTask.new(task1, task2)
    yielded = []
    seq.now({a:1}, {b:2}) do |data, options|
      yielded.push([data, options])
    end
    expect(yielded).to eq([[{a:1,c:3,d:4},{b:2}]])
  end

  it 'executes the task regardless of whether or not a block is given' do
    executed = []
    task1 = factory.task { |data, options|
      r = data.merge(c:3)
      executed.push([r, options])
      r
    }
    task2 = factory.task { |data, options|
      r = data.merge(d:4)
      executed.push([r, options])
      r
    }
    seq = Observed::SequenceTask.new(task1, task2)
    seq.now({a:1}, {b:2})
    expect(executed).to eq([[{a:1,c:3},{b:2}], [{a:1,c:3,d:4},{b:2}]])
  end
end

describe Observed::Task do
  context 'in simple use cases' do
    let(:factory) {
      Observed::TaskFactory.new(:executor => Observed::BlockingExecutor.new)
    }
    context 'when the options as input are given' do
      it 'propagates the options from the input' do
        task1 = factory.task { |data, options|
          expect(options).to eq({b:2})
          data
        }
        task2 = factory.task { |_, options|
          expect(options).to eq({b:2})
        }
        seq = task1.then(task2)
        seq.now({a:1}, {b:2})
      end
      it 'allows to override the options from the input in subsequent tasks' do
        task1 = factory.task { |data, options|
          expect(options).to eq({b:2})
          [data, {b:3}]
        }
        task2 = factory.task { |_, options|
          expect(options).to eq({b:3})
        }
        seq = task1.then(task2)
        seq.now({a:1}, {b:2})
      end
    end
    context 'when the options as input are not given' do
      it 'provides nil in the block parameter and allows to override it in subsequent tasks' do
        task1 = factory.task { |data, options|
          expect(options).to be_nil
          [data, {b:3}]
        }
        task2 = factory.task { |_, options|
          expect(options).to eq({b:3})
        }
        seq = task1.then(task2)
        seq.now({a:1})
      end
    end
  end
  context 'when used in an immutable way' do
    it 'propagates the resulting data to next tasks' do
      factory = Observed::TaskFactory.new(:executor => Observed::BlockingExecutor.new)
      output = mock('output')
      input_data = { input: 1 }
      a = factory.task { |data|
        data.merge(a: 2)
      }
      b = factory.task { |data, options|
        data.merge(b: 3)
      }
      c = factory.task { |data, options|
        output.write data.merge(c: 4)
      }
      d = factory.task { |data|
        output.write data.merge(d: 5)
      }
      foo = a.then(b).then(c, d)
      output.expects(:write).with({input:1,a:2,b:3,c:4})
      output.expects(:write).with({input:1,a:2,b:3,d:5})
      foo.now(input_data)
    end
  end

  context 'when used in a mutable way' do
    it 'propagates the resulting data to next tasks' do
      factory = Observed::TaskFactory.new(:executor => Observed::BlockingExecutor.new)
      output = mock('output')
      input_data = { input: 1 }
      a = factory.mutable_task { |data|
        data.merge(a: 2)
      }
      b = factory.task { |data, options|
        data.merge(b: 3)
      }
      c = factory.task { |data, options|
        output.write data.merge(c: 4)
      }
      d = factory.task { |data|
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
      factory = Observed::TaskFactory.new(
          :executor => Observed::BlockingExecutor.new,
          :listener => listener
      )
      output = mock('output')
      input_data = { input: 1 }
      a = factory.task { |data|
        data.merge(a: 2)
      }
      b = factory.task { |data, options|
        data.merge(b: 3)
      }
      c = factory.task { |data, options|
        output.write data.merge(c: 4)
      }
      d = factory.task { |data|
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
