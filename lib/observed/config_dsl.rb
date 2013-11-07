require 'observed/observer'

module Observed
  # The DSL to describe Observed's configuration.
  # @example
  # ConfigDSL.new.instance_eval user_code_from_configuration_file
  class ConfigDSL

    def initialize
    end

    def eval_file(file)
      @file = File.expand_path(file)
      working_directory File.dirname(@file)
      instance_eval(File.read(file), @file)
    end

    def working_directory(wd=nil)
      @working_directory = wd if wd
      @working_directory
    end

    def require_relative(lib)
      path = File.expand_path("#{working_directory}/#{lib}")
      logger.debug "Require '#{path}'"
      require path
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
      { observers: inputs, reporters: outputs }
    end

    # Load the file and evalute the containing code in context of this object(a.k.a DSL).
    # @param [String|Pathname] file The path to Ruby script containing the code in Observed's configuration DSL,
    # typically `observed.conf`.
    def load!(file)
      eval_file file
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def inputs
      @observations ||= {}
    end

    def outputs
      @reporters ||= {}
    end
  end
end
