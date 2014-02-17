require 'observed/observer'
require 'observed/reporter'
require 'observed/translator'
require 'observed/task'

module Observed
  # An yet another cushion from the deprecated plugin interface to the new plugin interface
  class FakeSystem

    def initialize(args)
      @time = args[:time] || Time.now
    end

    def report(tag, time, data=nil)
      options = nil
      if tag.is_a?(::Hash)
        data = tag
        options = time || {}
        tag = nil
      elsif tag.is_a?(String) && time.is_a?(::Hash)
        options = data
        data = time
      else
        options = {tag: tag, time: time}
      end
      options ||= {}
      options[:tag] ||= tag
      options[:time] ||= now
      @reported = [data, options]
    end

    def reported
      @reported
    end

    def now
      @time
    end
  end

  class ObservedTaskFactory

    def initialize(args={})
      @task_factory = args[:task_factory] || Observed::TaskFactory.new(executor: Observed::BlockingExecutor.new)
    end

    # Convert the observer/translator/reporter to a task
    def convert_to_task(underlying)
      if underlying.is_a? Observed::Observer
        @task_factory.task {|data, options|
          options ||= {}
          m = underlying.method(:observe)
          fake_system = FakeSystem.new(time: options[:time])
          # For 0.1.0 compatibility
          underlying.configure(system: fake_system)
          underlying.configure(tag: options[:tag]) unless underlying.get_attribute_value(:tag)
          result = dispatch_method m, data, options
          fake_system.reported || result
        }
      elsif underlying.is_a? Observed::Reporter
        @task_factory.task {|data, options|
          options ||= {}
          m = underlying.method(:report)
          dispatch_method m, data, options
        }
      elsif underlying.is_a? Observed::Translator
        @task_factory.task {|data, options|
          options ||= {}
          m = underlying.method(:translate)
          dispatch_method m, data, options
        }
      else
        fail "Unexpected type of object which can not be converted to a task: #{underlying}"
      end
    end

    def dispatch_method(m, data, options)
      num_parameters = m.parameters.size
      case num_parameters
      when 0
        m.call
      when 1
        m.call data
      when 2
        m.call data, options
      when 3
        # Deprecated. This is here for backward compatiblity
        m.call options[:tag], options[:time], data
      else
        fail "Unexpected number of parameters for the method `#{m}`: #{num_parameters}"
      end
    end

  end
end
