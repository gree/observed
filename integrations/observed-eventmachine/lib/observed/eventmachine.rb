require "eventmachine"
require "observed/eventmachine/version"

module Observed
  module EM

    # Schedule the observation to run it periodically
    # @param [Float|Fixnum] seconds
    # @param [Hash] args
    # @option args [String] :run The tag of the observation to schedule running. It is the one registered via the code
    #                            `observe tag, via: 'observer_plugin_name'`.
    def every(seconds, args)
      @builder.every seconds, args
    end

    # Start EventMachine and run scheduled observations.
    def start
      ::EM.run do
        Signal.trap("INT")  { ::EventMachine.stop }
        Signal.trap("TERM") { ::EventMachine.stop }
        @builder.periodic_tasks.each do |periodic_task|
          ::EM.add_periodic_timer(periodic_task.seconds) do
            ::EM.defer { run(periodic_task.tag) }
          end
        end
      end
    end

    # Automatically called on `extend Observed::EM`
    def init_observed_em_builder
      @builder = Builder.new
    end

    def self.extended(klass)
      klass.init_observed_em_builder
    end

    class Builder

      # Schedule the observation to run it periodically.
      # Scheduled observations can be obtained later by calling the method `periodic_tasks`.
      # @param [Float|Fixnum] seconds The interval to run the observation, in seconds.
      # @param [Hash] args
      # @option args [String] :run The tag of the observation to schedule running. It is the one registered via the code
      #                            `observe tag, via: 'observer_plugin_name'`.
      def every(seconds, args)
        periodic_tasks << PeriodicTask.new(seconds, args)
      end

      def periodic_tasks
        @periodic_tasks ||= []
      end
    end

    class PeriodicTask
      attr_reader :seconds
      attr_reader :args

      def initialize(seconds, args)
        @seconds = seconds
        @args = args
      end

      def tag
        args[:run]
      end
    end

  end
end
