require 'observed/pluggable'
require 'observed/plugin/observation_result'
require 'observed/plugin/observation_results'

module Observed

  module Configurable

    module ClassMethods
      # @param [Symbol] name
      def attribute(name)
        define_method(name) do
          instance_variable_get("@#{name.to_s}") || @attributes[name] || self.class.defaults[name] || fail_because_of_non_configured_parameter(name)
        end
      end

      def default(args)
        @defaults = defaults.merge(args)
      end

      def defaults
        @defaults ||= {}
      end

    end

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

    private

    def fail_because_of_non_configured_parameter(name)
      fail NotConfiguredError.new("The parameter `#{name}` is not configured.")
    end

  end

  class Plugin
    include Pluggable
    include Configurable

    class NotConfiguredError < RuntimeError; end

    def initialize(args={})
      @attributes = args.dup.freeze
    end

    attribute :name
    attribute :check_name
    attribute :timeout_in_milliseconds
    attribute :number_of_trials

    def run_all_health_checks
      results = number_of_trials.times.map do
        before = Time.now
        content = run_health_check_once
        after = Time.now
        elapsed_time = ((after - before) * 1000.0).to_i
        ObservationResult.new(
            :elapsed_time_in_milliseconds => elapsed_time,
            :check_name => check_name,
            :check_content => content
        )
      end
      ObservationResults.new(results)
    end

    def run_health_check_once
      raise NotImplementedError.new
    end

    class << self
      def create(args)
        self.new(args)
      end
    end

    def default_value_for(name)
      self.class.defaults[name]
    end

  end
end
