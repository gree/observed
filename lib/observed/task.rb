require 'logger'
require 'thread'

module Observed
  class Task
    attr_accessor :name

    def then(*tasks)
      next_task = if tasks.size == 1
                   tasks.first
                 elsif tasks.size > 1
                   ParallelTask.new(tasks)
                 else
                   raise 'No tasks to be executed'
                 end
      SequenceTask.new(self, next_task)
    end

    def compose(first_task)
      second_task = self

      first_task.then(second_task)
    end
  end

  class MutableTask
    def initialize(current_task)
      @current_task = current_task
      @mutex = Mutex.new
    end
    def now(data={}, options=nil)
      @current_task.now(data, options) do |data, options2|
        yield data, (options2 || options) if block_given?
      end
    end
    def then(*tasks)
      @mutex.synchronize do
        @current_task = @current_task.then(*tasks)
      end
      self
    end
  end

  class SequenceTask < Observed::Task
    attr_reader :base_task
    def initialize(base_task, next_task)
      @base_task = base_task
      @next_task = next_task
    end
    def now(data={}, options=nil)
      @base_task.now(data, options) do |data, options2|
        @next_task.now(data, (options2 || options)) do |data, options3|
          yield data, (options3 || options2 || options) if block_given?
        end
      end
    end
  end

  class ParallelTask < Observed::Task
    def initialize(tasks)
      @tasks = tasks || fail('tasks missing')
      @next_task = NoOpTask.instance
    end
    def now(data={}, options=nil)
      @tasks.each do |task|
        task.now(data, options) do |data, options2|
          yield data, (options2 || options) if block_given?
        end
      end
    end
  end

  class NoOpTask < Observed::Task
    def now(data={}, options={}); end
    def self.instance
      SINGLETON_INSTANCE
    end
    SINGLETON_INSTANCE = NoOpTask.new
  end

  class ProcTask < Observed::Task
    def initialize(args, &block)
      @executor = args[:executor] || fail('Missing a value for :executor')
      @listener = args[:listener] || fail('Missing a value for :listener')
      @logger = args[:logger]
      @block = block
      @next_task = NoOpTask.instance

      if @logger.nil?
        @logger = ::Logger.new(STDERR)
        @logger.level = ::Logger::WARN
      end
    end
    def now(data={}, options=nil)
      @executor.submit {
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

  class TaskListener
    def on_result(data={}, options={})

    end
  end

  class TaskFactory
    def initialize(args)
      @executor = args[:executor] || fail('Missing a value for :executor')
      @listener = args[:listener] || TaskListener.new
    end

    def task(&block)
      ProcTask.new(executor: @executor, listener: @listener, &block)
    end

    def mutable_task(&block)
      MutableTask.new(task(&block))
    end

    def parallel(tasks)
      ParallelTask.new(tasks)
    end
  end

  class Executor
    def submit; end
  end

  class BlockingExecutor
    def submit
      yield
    end
  end

  class ThreadExecutor
    def submit
      Thread.start {
        yield
      }
    end
  end
end
