require 'spec_helper'

require 'observed'
require 'logger'

module ObservedMemo
  # a.k.a Blocking Poller
  class Poller
    def poll
      fail 'Not Implemented'
    end
  end

  class DefaultPoller < Poller
    include Observed::Configurable
    attribute :reader
    def poll
      reader.read
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

  class ExamplePoller < Poller
    def poll
      "result"
    end
  end

  class ExampleConcurrentPoller < ConcurrentPoller
    def poll
      Promise.succeeded("result").future
    end
  end

  class SingleThreadedBlockingExecutionContext < ExecutionContext
    # a.k.a AwaitingConcurrentPoller
    class BlockingConcurrentPoller < ConcurrentPoller

      include Observed::Configurable

      attribute :poller

      def poll
        promise = begin
          Promise.succeeded(poller.poll)
        rescue => e
          Promise.failed(e)
        end
        promise.future
      end
    end

    class ComponentFactoryCreator

      include Observed::Configurable

      attribute :poller_plugins
      attribute :context

      def poller(name, args={})
        poller_class = poller_pugins[name]
        if poller_class.ancestors.include? Poller
          BasicFactory.new { BlockingConcurrentPoller.new(args.merge(poller: poller_class.new(args))) }
        elsif poller_class.ancestors.include? ConcurrentPoller
          BasicFactory.new { poller_class.new(args) }
        else
          fail "Unexpected type of poller class found for the name(#{name.inspect}): #{poller_class}"
        end
      end
    end

    class Executor

      include Observed::Configurable

      include Observed::Logging

      def initialize(config)
        @config = config
        @pollers = {}
        @config.poller_factories.each do |name, factory|
          @pollers[name] ||= factory.create
        end
        @logger = config[:logger] || Logger.new(STDOUT)
      end

      def poll(name=nil)
        if name
          future_data = @pollers[name].poll
          future_data.on_success { |data|
            observe(name, data)
          }
        else
          @pollers.each do |name, poller|
            future_data = poller.poll
            future_data.on_success { |data|
              observe(name, data)
            }
          end
        end
      end

      def observe(name, data)
        future = @observers[name].observe(data)
        future.on_success { |tag, time, data|
          report(tag, time, data)
        }
      end

      def report(tag, time, data)
        @reporters.each do |reporter|
          if reporter.match(tag)
            result = reporter.report(tag, time, data)
            result.on_success { |message|
              debug %Q|report(#{tag.inspect}, #{time.inspect}, #{data.inspect} #=> #{message.inspect}|
            }
            result.on_failure { |error|
              # Replace this using nesty later
              raise error
            }
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
    include Observed::Configurable
    attribute :component_factory
    attribute :poller_factories, default: {}
    def poll(name, args={})
      poller_factories[name] = component_factory.poller(name, args)
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

describe ObservedMemo::ExecutionContext do
  let(:executor) { mock('executor') }
  let(:config_builder) {
    ObservedMemo::ConfigBuilder.new(component_factory: component_factory, )
  }
  let(:component_factory) {
    ObservedMemo::ComponentFactoryCreator.new(context: context, poller_plugins: poller_plugins)
  }
  let(:poller_plugins) {
    {
      'example' => ObservedMemo::ExamplePoller,
      'example2' => ObservedMemo::ExampleConcurrentPoller
    }
  }
  subject {
    ObservedMemo::ExecutionContext.new(executor: executor)
  }
  it "doesn't smoke" do
    expect { subject }.to_not raise_error

    #subject.define do
    #  # Creates the example poller and the default observer
    #  observe 'foo', via: 'example'
    #end
    #
    #result = subject.execute do
    #  poll 'foo'
    #end
    #ObservedMemo::DefaultObserver.any_instance.expects(:observe).with('foo', 'result')
  end
end
