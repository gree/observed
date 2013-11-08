Feature: Be testable in a single command

  In order to try Observed to see the basic usage usage of it,
  I want to write a config file and test it by running Observed in a single command

  Scenario: Create a .rb file containing Observed configuration and run it with the observed-oneshot command
    Given a file named "test.rb" with:
    """
    class Test < Observed::Observer
      plugin_name 'test'
      def observe
        system.report(tag, {foo:1})
      end
    end

    observe 'foo', via: 'test'

    report /foo/, via: 'stdout'
    """
    When I run `observed-oneshot -d test.rb`
    Then the output should contain:
    """
    foo {:foo=>1}
    """
