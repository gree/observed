Feature: Routing observed data without matching tags

  In order to use Observed when the user's user-case is too simple that even tags are not needed
  I want to write configs with reporters which have no regexp patterns to match observed data

  Scenario: Create a .rb file containing Observed configuration and run it with the observed-oneshot command
    Given a file named "test.rb" with:
    """
    require 'observed'

    include Observed

    class Test < Observed::Observer
      plugin_name 'test'
      def observe
        system.report(tag, {foo:1})
      end
    end

    observe_then_report = (observe 'foo', via: 'test')
      .then(report via: 'stdout')

    observe_then_report.now
    """
    When I run `ruby test.rb`
    Then the output should contain:
    """
    {:foo=>1}
    """
    Then the output should not contain:
    """
    Error
    """
