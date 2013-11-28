require 'observed/observer'
require 'observed/reporter'
require 'observed/translator'
require 'observed/job'

module Observed
  # An yet another cushion from the deprecated plugin interface to the new plugin interface
  class FakeSystem

    def initialize(args)
      @time = args[:time] || Time.now
    end

    def report(tag, time, data=nil)
      if time.nil?
        data = time
        time = Time.now
      end
      @reported = [data, {tag: tag, time: time}]
    end

    def reported
      @reported
    end

    def now
      @time
    end
  end

  class ExecutionJobFactory

    def initialize(args={})
      args_copy = args.clone
      args_copy[:executor] ||= Observed::BlockingJobExecutor.new
      @job_factory = Observed::JobFactory.new(args_copy)
    end

    # Convert the observer/translator/reporter to a job
    def convert_to_job(underlying)
      if underlying.is_a? Observed::Observer
        @job_factory.job {|data, options|
          m = underlying.method(:observe)
          fake_system = FakeSystem.new(time: options[:time])
          underlying.configure(system: fake_system)
          result = case m.parameters.size
                   when 0
                     underlying.observe
                   when 1
                     underlying.observe(data)
                   when 2
                     # Deprecated. This is here for backward compatiblity
                     underlying.observe(data, options)
                   end
          fake_system.reported || result
        }
      elsif underlying.is_a? Observed::Reporter
        @job_factory.job {|data, options|
          m = underlying.method(:report)
          num_parameters = m.parameters.size
          case num_parameters
          when 1
            underlying.report(data)
          when 2
            underlying.report(data, options)
          when 3
            # Deprecated. This is here for backward compatiblity
            underlying.report(options[:tag], options[:time], data)
          else
            fail "Unexpected number of parameters for the method `report`: #{num_parameters}"
          end
        }
      elsif underlying.is_a? Observed::Translator
        @job_factory.job {|data, options|
          m = underlying.method(:translate)
          num_parameters = m.parameters.size
          case num_parameters
          when 1
            underlying.translate(data)
          when 2
            underlying.translate(data, options)
          when 3
            # Deprecated. This is here for backward compatiblity
            underlying.translate(options[:tag], options[:time], data)
          else
            fail "Unexpected number of parameters for the method `translate`: #{num_parameters}"
          end
        }
      else
        fail "Unexpected type of object which can not be converted to a job: #{underlying}"
      end
    end

  end
end
