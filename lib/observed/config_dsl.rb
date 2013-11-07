require 'observed/observer'
require 'observed/configurable'
require 'forwardable'

module Observed
  # The DSL to describe Observed's configuration.
  # @example
  # context = ConfigDSL.new(builder: the_builder)
  # context.eval_file observed_conf_file(a.k.a user code describes Observed configuration)
  # context.config #=> can be used to instantiate Observed::System
  class ConfigDSL

    extend Forwardable

    include Observed::Configurable

    def_delegators :@builder, :observe, :report, :read, :write

    attribute :builder

    def initialize(args)
      args[:builder] || fail("The key :builder must exist in #{args}")
      @builder = args[:builder]

      configure(args)
    end

    def eval_file(file)
      @file = File.expand_path(file)
      working_directory File.dirname(@file)
      code = File.read(file)
      logger.debug "Evaluating: #{code}"
      instance_eval(code, @file)
    end

    # The `current directory` in which `require_relative` finds source files
    def working_directory(wd=nil)
      @working_directory = wd if wd
      @working_directory
    end

    # The replacement for Ruby's built-in `require_relative`.
    # Although the built-in one can not be used in `eval` or `instance_eval` or etc because
    # there is no `current file` semantics in `eval`, this replacement takes the file which is going to be evaluated
    # as the `current file`.
    # Thanks to this method, we can use `require_relative` in observed.conf files both when it is evaluated with `eval`
    # and when it is evaluated in result of `require`.
    def require_relative(lib)
      path = File.expand_path("#{working_directory}/#{lib}")
      logger.debug "Require '#{path}'"
      require path
    end

    # Build and returns the Observed configuration
    # @return [Observed::Config]
    def config
      @builder.build
    end

    # Load the file and evaluate the containing code in context of this object(a.k.a DSL).
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
