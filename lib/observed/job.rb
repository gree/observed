require 'logger'
require 'thread'

module Observed
  class Job
    attr_accessor :name

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

    def compose(first_job)
      second_job = self

      first_job.then(second_job)
    end
  end

  class MutableJob
    def initialize(current_job)
      @current_job = current_job
      @mutex = Mutex.new
    end
    def now(data={}, options=nil)
      @current_job.now(data, options) do |data, options2|
        yield data, (options2 || options) if block_given?
      end
    end
    def then(*jobs)
      @mutex.synchronize do
        @current_job = @current_job.then(*jobs)
      end
      self
    end
  end

  class SequenceJob < Job
    attr_reader :base_job
    def initialize(base_job, next_job)
      @base_job = base_job
      @next_job = next_job
    end
    def now(data={}, options=nil)
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
    def now(data={}, options=nil)
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
      @listener = args[:listener] || fail('Missing a value for :listener')
      @logger = args[:logger]
      @block = block
      @next_job = NoOpJob.instance

      if @logger.nil?
        @logger = ::Logger.new(STDERR)
        @logger.level = ::Logger::WARN
      end
    end
    def now(data={}, options=nil)
      @executor.execute {
        result = @block.call(data, options)
        yield result if block_given?
        notify_listener(data: data, options: options, result: result)
      }
    end

    private

    def notify_listener(args)
      return unless @listener

      data = args[:data]
      options = args[:options]
      result = args[:result]

      @logger.debug "Notifying listeners with the result(#{result}) generated from the input data(#{data}) and the options(#{options})"

      if result.is_a? ::Hash
        if options
          @listener.on_result(result, options)
        else
          @listener.on_result(result)
        end
      elsif result.is_a? ::Array
        if result.size == 1 && options
          @listener.on_result(result, options)
        elsif result.size == 2
          @listener.on_result(*result)
        end
      end
    end
  end

  class JobListener
    def on_result(data={}, options={})

    end
  end

  class JobFactory
    def initialize(args)
      @executor = args[:executor] || fail('Missing a value for :executor')
      @listener = args[:listener] || JobListener.new
    end

    def job(&block)
      ProcJob.new(executor: @executor, listener: @listener, &block)
    end

    def mutable_job(&block)
      MutableJob.new(job(&block))
    end

    def parallel(jobs)
      ParallelJob.new(jobs)
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
