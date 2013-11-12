require 'observed/configurable'

module Observed
  module Logging
    include Observed::Configurable

    # !@attribute [r] logger
    #  @return [Logger]
    attribute :logger

    # @return [Boolean] `true` if a value is set for the attribute :logger
    def logging_enabled?
      has_attribute_value? :logger
    end

    # Log the debug message through the logger configured via the :logger attribute
    # @param [String] message
    def log_debug(message)
      logger.debug message if logging_enabled?
    end

    # Log the info message through the logger configured via the :logger attribute
    # @param [String] message
    def log_info(message)
      logger.info message if logging_enabled?
    end

    # Log the warn message through the logger configured via the :logger attribute
    # @param [String] message
    def log_warn(message)
      logger.warn message if logging_enabled?
    end

    # Log the error message through the logger configured via the :logger attribute
    # @param [String] message
    def log_error(message)
      logger.error message if logging_enabled?
    end
  end
end
