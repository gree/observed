require 'observed/observer'
require 'observed/reporter'

module Observed
  class System

    def initialize(config)
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
      outputs.each do |tag_pattern, output|
        if output.match(tag)
          output.report(tag, time, data)
        end
      end
    end

    def run(observation_name=nil)

      if observation_name
        inputs_to_run = inputs.reject { |name, _| name != observation_name }
        fail "No configuration found for observation name '#{observation_name}'" if inputs_to_run.empty?
      else
        inputs_to_run = inputs
      end

      inputs_to_run.map do |tag, input|
        logger.debug "Observe: #{tag}"
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

    def input_plugins
      @plugins ||= begin
        input_plugins = {}
        Observed::Observer.select_named_plugins.each do |plugin|
          input_plugins[plugin.plugin_name] = plugin
        end
        input_plugins
      end
    end

    def output_plugins
      @output_plugins ||= begin
        output_plugins = {}
        Observed::Reporter.select_named_plugins.each do |plugin|
          output_plugins[plugin.plugin_name] = plugin
        end
        output_plugins
      end
    end

    def inputs
      @inputs ||= begin

        input_configs = config.inputs

        inputs = {}

        input_configs.each do |tag, input_config|
          plugin_name = input_config[:plugin] || fail(RuntimeError, %Q|Missing plugin name for the tag "#{tag}" in "#{input_config}" in "#{config}".|)
          plugin = input_plugins[plugin_name] || fail(RuntimeError, %Q|The plugin named "#{plugin_name}" is not found in plugins list "#{input_plugins}".|)
          updated_config = input_config.merge(tag: tag)
          input = plugin.new(updated_config)
          input.configure(system: self, logger: logger)
          inputs[tag] = input
        end

        inputs
      end
    end

    def outputs
      @outputs ||= begin

        output_configs = config.outputs

        outputs = {}

        output_configs.each do |tag_pattern, output_config|
          plugin_name = output_config[:plugin] || fail(RuntimeError, %Q|Missing plugin name for the output for "#{tag_pattern}" in "#{output_config}" in #{config}.|)
          plugin = output_plugins[plugin_name] || fail(RuntimeError, %Q|The plugin named "#{plugin_name}" is not found in plugins list "#{output_plugins}".|)
          updated_config = output_config.merge(tag_pattern: Regexp.new(tag_pattern))
          output = plugin.new(updated_config)
          output.configure(system: self, logger: logger)
          outputs[tag_pattern] = output
        end

        outputs
      end
    end

  end
end
