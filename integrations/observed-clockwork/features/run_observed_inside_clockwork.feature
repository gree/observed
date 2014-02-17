Feature: Running Observed inside Clockwork

  In order to integrate Observed with Clockwork,
  I want to configure Clockwork to run Observed.

  Scenario: Create a .rb file containing Observed code and run it with the ruby command
    Given a file named "observed.conf" with:
    """
    require 'observed/builtin_plugins'
    require_relative 'foo_plugin'

    observe 'foo_1', via: 'foo'

    report /foo_1/, via: 'stdout'
    """
    Given a file named "foo_plugin.rb" with:
    """
    module OneshotSpec
      class FooPlugin < Observed::Observer

        plugin_name 'foo'

        default timeout_in_milliseconds: 5000
        default number_of_trials: 10

        def observe
          sleep_duration = rand / 20
          sleep sleep_duration
          ::Thread.start {
            sleep 1
            exit
          }
          system.report(tag, {text: "Foo #{sleep_duration}"})
        end

        def logger
          @logger ||= Logger.new(STDOUT)
        end
      end
    end
    """
    Given a file named "clockwork.rb" with:
    """
    require 'clockwork'
    require 'observed/clockwork'

    include Clockwork
    include Observed::Clockwork

    register_observed_handler :config_file => File.dirname(__FILE__) + '/observed.conf'

    every(10.seconds, 'foo_1')
    """
    When I run `clockwork clockwork.rb`
    Then the output should contain:
    """
    00 foo_1 {:text=>"Foo
    """
