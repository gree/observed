require 'logger'
require 'observed/plugin'
require 'observed/config_dsl'

module Observed

  module Application
    # The application which is usually ran from CLI to run health-checks and write the results to a log file, and then exit.
    # An "Oneshot" application is the opposite of a "Daemon" or "Resident" application.
    class Oneshot
      # @option config [String]
      def initialize(config)
        @config = config
      end

      def config
        @config || fail('Missing configuration for Application::Oneshot')
      end

      def load_default_plugins
        load_plugins_from_directory! "#{File.dirname(__FILE__)}/plugins"
      end

      def load_plugins_from_directory!(dir)
        $LOAD_PATH.unshift(dir)
        plugin_names = Dir.glob("#{File.join(dir, '*.rb')}").each do |rb_file_path|
          File.basename(rb_file_path)
        end

        plugin_names.each do |name|
          require name
        end
      end

      def plugins
        @plugins ||= begin
          plugins = {}
          Observed::Plugin.plugins.each do |plugin|
            plugins[plugin.plugin_name] = plugin
          end
          plugins
        end
      end

      def run(observation_name=nil)
        configs = config.dup
        if observation_name
          configs.reject! { |name, c| name != observation_name }
          fail "No configuration found for observation name '#{observation_name}'" if configs.empty?
        end
        result = configs.map do |check_name, check_config|
          plugin_name = check_config[:plugin] || fail(RuntimeError, %Q|Missing plugin name for the check "#{check_name}" in "#{check_config}" in "#{config}".|)
          plugin = plugins[plugin_name] || fail(RuntimeError, %Q|The plugin named "#{plugin_name}" is not found in plugins list "#{plugins}".|)
          updated_config = check_config.merge({:check_name => check_name})
          check_results = plugin.new(updated_config).run_all_health_checks
          freq = {}
          check_results.each do |r|
            freq[r.check_content] = (freq[r.check_content] || 0) + 1
          end
          logger.info "#{check_name}.#{plugin_name}: #{freq}"
          check_results
        end
        logger.debug "result: #{result}"
        result
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
                     config_dsl = Observed::ConfigDSL.new(:plugins_directory => plugins_directory)
                     config_dsl.instance_eval(File.read(args[:config_file]), args[:config_file])
                     config_dsl.config
                   else
                     args[:config]
                   end
          new(config)
        end
      end

    end
  end
end
