require 'spec_helper'
require 'observed/task'

describe Observed::TaskFactory do
  context 'when the executor not given' do
    it 'fails to initialize' do
      expect { Observed::TaskFactory.new() }.to raise_error
    end
  end

  context 'when a logger given' do
    it 'may prefer the given logger over the default one' do
      Observed::TaskFactory.new(executor: mock('executor'), logger: ::Logger.new(STDERR))
    end
  end
end
