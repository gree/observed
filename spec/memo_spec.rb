require 'spec_helper'

require 'observed'

module Observed
  # a.k.a Blocking Poller
  class Poller
    def poll
      fail 'Not Implemented'
    end
  end

  class DefaultPoller < Poller
    include Observed::Configurable
    attribute :reader
    attribute :output
    def poll
      data = reader.read
      output.write data
    end
  end

  class Promise

    def future
      @future ||= Future.new
    end

    def success(data)
      future.success(data)
    end

    def failure(error)
      future.failure(error)
    end

    def self.succeeded(data)
      Promise.new.success(data)
    end

    def self.failed(error)
      Promise.new.failure(error)
    end
  end

  class Future

    def success(data)
      @success_callbacks.reject! { |c| c.call data; true }
    end

    def failure(error)
      @failure_callbacks.reject! { |c| c.call error; true }
    end

    def on_success(&block)
      @success_callbacks << block
    end

    def on_failure(&block)
      @failure_callbacks << block
    end
  end

  class ConcurrentPoller
    def poll
      fail 'Not Implemented'
    end
  end

  class Factory
    def create
      fail 'Not Implemented'
    end
  end

  class BasicFactory < Factory
    def initialize(&block)
      @factory = block
    end
    def create
      @factory.call
    end
  end

  class ExecutionContext
    def initialize(args)
      @executor = args[:executor]
    end
    def poll(name)
      @executor.poll(name)
    end

    def observe(name, data)
      @executor.observe(name, data)
    end

    def report(tag, time, data)
      @executor.report(tag, time, data)
    end
  end

  class SingleThreadedBlockingExecutionContext < ExecutionContext
    class BlockingConcurrentPoller < ConcurrentPoller
      include Observed::Configurable
      attribute :poller
      def poll
        begin
          Promise.succeeded(poller.poll).future
        rescue => e
          Promise.failed(e).future
        end
      end
    end

    DefaultConcurrentPoller = BlockingConcurrentPoller

    class ComponentFactoryCreator
      include Observed::Configurable
      attribute :poller_plugins
      attribute :context
      def poller(name, args={})
        poller_class = poller_pugins[name]
        if poller_class.ancestors.include? Poller
          BasicFactory.new { DefaultConcurrentPoller.new(args.merge(context: context, poller: poller_class.new(args))) }
        elsif poller_class.ancestors.include? ConcurrentPoller
          BasicFactory.new { poller_class.new(args.merge(context: context)) }
        end
      end
    end

    class Executor
      def initialize(config)
        @config = config
        @pollers = {}
        @config.poller_factories.each do |name, factory|
          @pollers[name] ||= factory.create
        end
      end
      def poll(name=nil)
        if name
          @pollers[name].poll
        else
          @pollers.each(&:poll)
        end
      end
      def observe(name, data)
        @observers[name].observe(data)
      end
      def report(tag, time, data)
        @reporters.each do |reporter|
          if reporter.match(tag)
            reporter.report(tag, time, data)
          end
        end
      end
    end
  end

  class MultiThreadedNonBlockingExecutionContext < ExecutionContext

    class ThreadedConcurrentPoller < ConcurrentPoller
      include Observed::Configurable
      attribute :poller
      def poll
        promise = Promise.new
        Thread.start {
          begin
            promise.success(poller.poll)
          rescue => e
            promise.failure(e)
          end
        }
        promise.future
      end
    end

    class ComponentFactory
      def poller(name, args={})
        poller_class = poller_plugins[name]
        if poller_class.ancestors.include? Poller
          BasicFactory.new { ThreadedConcurrentPoller.new(args.merge(poller: poller_class.new(args))) }
        elsif poller_class.ancestors.include? ConcurrentPoller
          BasicFactory.new { poller_class.new(args) }
        end
      end
    end
  end

  class ConfigBuilder
    def poll(name, args={})
      poller_factories << component_factory.poller(name, args)
    end
  end

  class Output
    include Observed::Configurable
    def write(data)
      fail 'Not Implemented'
    end
  end

  class OutputToObserver < Output
    include Observed::Configurable
    attribute :observer
    def write(data)
      observer.observe data
    end
  end

  class DefaultObserver < Observed::Observer
    include Observed::Configurable
    def observe(data)
      system.report(tag, time, data)
    end
  end

  #class DefaultTranslator
  #  def translate(data)
  #    system.report(tag, time, data)
  #  end
  #end

  #interface.write tag, data
  # #=> translated to interface.write tag, time, data
  # interface ---- system ----- interface
end

describe Observed::ExecutionContext do
  let(:executor) { mock('executor') }
  it "doesn't smoke" do
    described_class.new(executor: executor)
  end
end
