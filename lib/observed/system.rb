require 'observed/observer'
require 'observed/reporter'

module Observed
  class System

    def initialize(args={})
      @config = args[:config] if args[:config]
      @logger = args[:logger] if args[:logger]
      @context = args[:context]
    end

    def config=(config)
      @config = config
    end

    def config
      @config
    end

    def report(tag, time, data=nil)
      if data.nil?
        data = time
        time = self.now
      end
      reporters.each do |reporter|
        if reporter.match(tag)
          reporter.report(tag, time, data)
        end
      end
    end

    def run(observation_name=nil, data=nil, options=nil)
      options = { tag: (options && options[:tag]) || observation_name, time: now }.merge(options || {})
      params = [data, options]
      if observation_name
        fail "No configuration found for observation name '#{observation_name}'" if @context.config_builder.group(observation_name).empty?
        @context.config_builder.run_group(observation_name).send :now, *params
      else
        observers_to_run = @context.config_builder.observers
        fail "No configuration found for observation name '#{observation_name}'" if observers_to_run.empty?
        observers_to_run.each do |o|
          o.send :now, *params
        end
      end
    end

    def now
      Time.now
    end

    def logger
      @logger || fail("BUG? No logger configured")
    end

  end

end
