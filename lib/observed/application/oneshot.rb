require 'logger'
require 'optparse'
require 'pathname'

require 'observed/config'
require 'observed/config_builder'
require 'observed/config_dsl'
require 'observed/observer'
require 'observed/system'

module Observed

  module Application
    # The application which is usually ran from CLI to run health-checks and write the results to a log file, and then exit.
    # An "Oneshot" application is the opposite of a "Daemon" or "Resident" application.
    class Oneshot

      class InvalidArgumentError < RuntimeError; end

      # @param [Observed::Config] config
      def initialize(config, sys)
        @config = config
        @system = sys
      end

      def config
        @config || fail('Missing configuration for Application::Oneshot')
      end

      def run(observation_name=nil)
        system.run(observation_name)
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      class << self
        def from_argv(argv)

          command_line_args = argv.dup

          args = {}

          opts = OptionParser.new
          opts.accept(Pathname) do |s,|
            Pathname.new(s)
          end
          opts.on('-d', '--debug') do
            args[:debug] = true
          end
          opts.on('-l LOG_FILE', '--l LOG_FILE', Pathname) do |log_file|
            args[:log_file] = log_file
          end

          opts.parse!(command_line_args)

          if command_line_args.size != 1
            fail InvalidArgumentError, "Invalid number of arguments #{command_line_args.size} where arguments are #{command_line_args}"
          end

          args[:config_file] = command_line_args.first

          create(args)
        end

        # @param [Hash<Symbol,String>] args
        # @option args [Array<String>] :argv The Ruby's `ARGV` like object which is treated as intialization parameters for Oneshoft application.
        def create(args)
          logger_out = if args[:log_file]
                         File.open(args[:log_file], 'a')
                       else
                         STDOUT
                       end
          logger = Logger.new(logger_out)
          logger.level = if args[:debug]
                           Logger::DEBUG
                         else
                           Logger::INFO
                         end
          sys = Observed::System.new(logger: logger)
          config = if args[:yaml_file]
                     YAML.load_file(args[:yaml_file])
                   elsif args[:config_file]
                     path = args[:config_file]
                     config_builder = Observed::ConfigBuilder.new(system: sys, logger: logger)
                     config_dsl = Observed::ConfigDSL.new(builder: config_builder, logger: logger)
                     config_dsl.eval_file(path)
                     config_dsl.config
                   elsif args[:config]
                     c = args[:config]
                     c
                   else
                     fail 'No configuration provided'
                   end
          config = if config.is_a? Hash
                     Observed::Config.create(config)
                   else
                     config
                   end
          sys.config = config
          new(config, sys)
        end
      end

      private

      def system
        @system
      end

    end
  end
end
