require 'logger'
require 'observed/input_plugin'
require 'observed/config_dsl'
require 'observed/config'
require 'observed/system'
require 'pathname'

module Observed

  module Application
    # The application which is usually ran from CLI to run health-checks and write the results to a log file, and then exit.
    # An "Oneshot" application is the opposite of a "Daemon" or "Resident" application.
    class Oneshot
      # @param [Observed::Config] config
      def initialize(config)
        @config = config
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
        # @param [Hash<Symbol,String>] args
        # @option args [Array<String>] :argv The Ruby's `ARGV` like object which is treated as intialization parameters for Oneshoft application.
        def create(args)
          plugins_directory = if args[:plugins_directory]
                                Pathname.new(args[:plugins_directory])
                              else
                                Pathname.new('.')
                              end
          config = if args[:yaml_file]
                     YAML.load_file(args[:yaml_file])
                   elsif args[:config_file]
                     config_dsl = Observed::ConfigDSL.new(plugins_directory: plugins_directory)
                     config_dsl.instance_eval(File.read(args[:config_file]), args[:config_file])
                     config_dsl.config
                   else
                     c = args[:config]
                     c
                   end
          config = if config.is_a? Hash
                     Observed::Config.create(config)
                   else
                     config
                   end
          new(config)
        end
      end

      private

      def system
        Observed::System.new(config)
      end

    end
  end
end
