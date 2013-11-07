require 'observed/observer'
require 'observed/reporter'

module Observed
  class System

    def initialize(config=nil)
      @config = config if config
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

    def run(observation_name=nil)

      if observation_name
        observers_to_run = observers.reject { |name, _| name != observation_name }
        fail "No configuration found for observation name '#{observation_name}'" if observers_to_run.empty?
      else
        observers_to_run = observers
      end

      observers_to_run.map do |input|
        input.observe
      end

    end

    def now
      Time.now
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    private

    def observers
      config.observers
    end

    def reporters
      config.reporters
    end

  end

  class YAML
    def observers
      config.observers
      @observers ||= begin

        observer_configs = config.observers

        observers = {}

        observer_configs.each do |tag, input_config|
          plugin_name = input_config[:plugin] || fail(RuntimeError, %Q|Missing plugin name for the tag "#{tag}" in "#{input_config}" in "#{config}".|)
          plugin = observer_plugins[plugin_name] || fail(RuntimeError, %Q|The plugin named "#{plugin_name}" is not found in plugins list "#{observer_plugins}".|)
          updated_config = input_config.merge(tag: tag)
          observer = plugin.new(updated_config)
          observer.configure(system: self, logger: logger)
          observers[tag] = observer
        end

        observers
      end
    end

    def reporters
      @reporters ||= begin

        reporter_configs = config.reporters

        reporters = {}

        reporter_configs.each do |tag_pattern, output_config|
          plugin_name = output_config[:plugin] || fail(RuntimeError, %Q|Missing plugin name for the output for "#{tag_pattern}" in "#{output_config}" in #{config}.|)
          plugin = reporter_plugins[plugin_name] || fail(RuntimeError, %Q|The plugin named "#{plugin_name}" is not found in plugins list "#{reporter_plugins}".|)
          updated_config = output_config.merge(tag_pattern: Regexp.new(tag_pattern))
          reporter = plugin.new(updated_config)
          reporter.configure(system: self, logger: logger)
          reporters[tag_pattern] = reporter
        end

        reporters
      end
    end
  end
end
