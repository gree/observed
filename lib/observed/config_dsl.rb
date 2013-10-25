module Observed
  class ConfigDSL

    def initialize(options)
      if options[:plugins_directory]
        @plugins_directory = options[:plugins_directory]
      end
    end

    def plugins_directory
      @plugins_directory ||= Pathname.new('.')
    end

    alias original_require require

    def require(lib)
      $LOAD_PATH.push plugins_directory.to_s
      #original_require "#{plugins_directory + lib}"
      original_require lib
      $LOAD_PATH.delete plugins_directory.to_s
    end

    def observe(observation_name, observation)
      if observations[observation_name]
        fail "An observation named '#{observation_name}' already exists."
      else
        observations[observation_name] = observation
      end
    end

    def observations
      @observations ||= {}
    end

    def config
      observations
    end
  end
end
