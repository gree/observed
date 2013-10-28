require 'observed/input_plugin'

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
      if inputs[observation_name]
        fail "An observation named '#{observation_name}' already exists."
      else
        inputs[observation_name] = observation
      end
    end

    def match(tag, output)
      if outputs[tag]
        fail "A `match` for the tag '#{tag}' already exists."
      else
        outputs[tag] = output
      end
    end

    def config
      { :inputs => inputs, :outputs => outputs }
    end

    def load!(file)
      code = File.read(file)
      instance_eval code, file
    end

    private

    def inputs
      @observations ||= {}
    end

    def outputs
      @outputs ||= {}
    end

    def plugins_directory
      @plugins_directory ||= Pathname.new('.')
    end
  end
end
