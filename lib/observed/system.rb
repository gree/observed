require 'observed/observer'
require 'observed/reporter'

module Observed
  class System

    def initialize(args={})
      @config = args[:config] if args[:config]
      @logger = args[:logger] if args[:logger]


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

    def run(observation_name=nil, data=nil)

      if observation_name
        observers_to_run = observers.reject { |o| o.tag != observation_name }
        fail "No configuration found for observation name '#{observation_name}'" if observers_to_run.empty?
      else
        observers_to_run = observers
      end

      observers_to_run.map do |input|
        input.observe data
      end

    end

    def now
      Time.now
    end

    def logger
      @logger || fail("BUG? No logger configured")
    end

    private

    def observers
      config.observers
    end

    def reporters
      config.reporters
    end

  end

end
