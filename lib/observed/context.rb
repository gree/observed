require 'logger'

require 'observed/system'
require 'observed/config_builder'
require 'observed/config_dsl'

module Observed
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
      @system ||= Observed::System.new(logger: logger)
    end

    def config_builder
      @config_builder ||= Observed::ConfigBuilder.new(system: system, logger: logger)
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
