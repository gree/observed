require 'spec_helper'
require 'observed/job'

describe Observed::JobFactory do
  context 'when the executor not given' do
    it 'fails to initialize' do
      expect { Observed::JobFactory.new() }.to raise_error
    end
  end

  context 'when a logger given' do
    it 'may prefer the given logger over the default one' do
      Observed::JobFactory.new(executor: mock('executor'), logger: ::Logger.new(STDERR))
    end
  end
end
