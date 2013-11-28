module Observed
  class Job
    def then(*jobs)
      next_job = if jobs.size == 1
                   jobs.first
                 elsif jobs.size > 1
                   ParallelJob.new(jobs)
                 else
                   raise 'No jobs to be executed'
                 end
      SequenceJob.new(self, next_job)
    end
  end

  class MutableJob
    def initialize(current_job)
      @current_job = current_job
    end
    def now(data={}, options={})
      @current_job.now(data, options) do |data, options2|
        yield data, (options2 || options) if block_given?
      end
    end
    def then(*jobs)
      @current_job = @current_job.then(*jobs)
      self
    end
  end

  class SequenceJob < Job
    attr_reader :base_job
    def initialize(base_job, next_job)
      @base_job = base_job
      @next_job = next_job
    end
    def now(data={}, options={})
      @base_job.now(data, options) do |data, options2|
        @next_job.now(data, (options2 || options)) do |data, options3|
          yield data, (options3 || options2 || options) if block_given?
        end
      end
    end
  end

  class ParallelJob < Job
    def initialize(jobs)
      @jobs = jobs || fail('jobs missing')
      @next_job = NoOpJob.instance
    end
    def now(data={}, options={})
      @jobs.each do |job|
        job.now(data, options) do |data, options2|
          yield data, (options2 || options) if block_given?
        end
      end
    end
  end

  class NoOpJob < Job
    def now(data={}, options={}); end
    def self.instance
      SINGLETON_INSTANCE
    end
    SINGLETON_INSTANCE = NoOpJob.new
  end

  class ProcJob < Job
    def initialize(args, &block)
      @executor = args[:executor] || fail('Missing a value for :executor')
      @block = block
      @next_job = NoOpJob.instance
    end
    def now(data={}, options={})
      @executor.execute {
        yield @block.call(data, options) if block_given?
      }
    end
  end

  class JobFactory
    def initialize(args)
      @executor = args[:executor] || fail('Missing a value for :executor')
    end
    def job(&block)
      ProcJob.new(executor: @executor, &block)
    end

    def mutable_job(&block)
      MutableJob.new(job(&block))
    end
  end

  class JobExecutor
    def execute; end
  end

  class BlockingJobExecutor
    def execute
      yield
    end
  end

  class ThreadedJobExecutor
    def execute
      Thread.start {
        yield
      }
    end
  end
end
