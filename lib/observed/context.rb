require 'logger'

require 'observed/system'
require 'observed/config_builder'
require 'observed/config_dsl'
require 'observed/task'
require 'observed/event_bus'

module Observed
  # The run context of an Observed system.
  # It can be initialized via parameters to automatically configure the system and everything needed such as the config
  # builder, the DSL, the logger, etc.
  class Context

    def initialize(args={})
      configure args
    end

    def configure(args)
      @logger ||= begin
        logger_out = if args[:log_file]
                       File.open(args[:log_file], 'a')
                     else
                       STDOUT
                     end
        Logger.new(logger_out)
      end

      @executor = args[:executor]

      set_log_level_to_debug(!!args[:debug])

      if args[:config_file]
        load_config_file(args[:config_file])
      end

      self
    end

    def logger
      @logger
    end

    def system
      @system ||= Observed::System.new(logger: logger, context: self)
    end

    def executor
      @executor ||= Observed::BlockingExecutor.new
    end

    def event_bus
      @event_bus ||= Observed::EventBus.new(task_factory: task_factory)
    end

    def task_factory
      @task_factory ||= Observed::TaskFactory.new(executor: executor)
    end

    def observed_task_factory
      @observed_task_factory ||= Observed::ObservedTaskFactory.new(task_factory: task_factory)
    end

    def config_builder
      @config_builder ||= Observed::ConfigBuilder.new(system: system, logger: logger, context: self)
    end

    def config_dsl
      Observed::ConfigDSL.new(builder: config_builder, logger: logger)
    end

    private

    def set_log_level_to_debug(enabled)
      @logger.level = if enabled
                        Logger::DEBUG
                      else
                        Logger::INFO
                      end

      @logger.debug "Enabling Debug logs." if enabled
    end

    def load_config_file(path)
      config_dsl.eval_file(path)
      system.config = config_dsl.config
    end

  end
end
