require 'observed/observer'

module Observed
  # The DSL to describe Observed's configuration.
  # @example
  # ConfigDSL.new.instance_eval user_code_from_configuration_file
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

    # We want to require Ruby scripts reside in the same directory of `observed.conf` a.k.a Observed's configuration.
    # For that, we have to mutate Ruby's LOAD_PATH but we also prefer mutating it locally in this method over
    # mutating it globally.
    def require(lib)
      $LOAD_PATH.push plugins_directory.to_s
      #original_require "#{plugins_directory + lib}"
      original_require lib
      $LOAD_PATH.delete plugins_directory.to_s
    end

    # @param [String] tag The tag which is assigned to data which is generated from this input and is sent to output
    # later
    # @param [Hash] input The configuration for each input conatining (1) which input plugin to use for this input and
    # (2) which parameters to pass to input plugin.
    def observe(tag, input)
      if inputs[tag]
        fail "An observation named '#{tag}' already exists."
      else
        inputs[tag] = input
      end
    end

    # @param [Regexp] tag The pattern to match inputs' tags
    # @param [Hash] output The configuration for each output containing (1) which output plugin to use for this output
    # and (2) which parameters to pass to the output plugin
    def match(tag, output)
      if outputs[tag]
        fail "A `match` for the tag '#{tag}' already exists."
      else
        outputs[tag] = output
      end
    end

    def config
      { inputs: inputs, outputs: outputs }
    end

    # Load the file and evalute the containing code in context of this object(a.k.a DSL).
    # @param [String|Pathname] file The path to Ruby script containing the code in Observed's configuration DSL,
    # typically `observed.conf`.
    def load!(file)
      code = File.read(file)
      instance_eval code, file
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end

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
