require 'observed/plugin'

module Observed
  class ConfigDSL

    alias original_require require

    def initialize(options={})
      configure(options)
    end

    def configure(options)
      if options[:plugins_directory]
        @plugins_directory = options[:plugins_directory]
      end
    end

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

    def config
      observations
    end

    def load!(file)
      code = File.read(file)
      instance_eval code, file
    end

    private

    def observations
      @observations ||= {}
    end

    def plugins_directory
      @plugins_directory ||= Pathname.new('.')
    end
  end
end
