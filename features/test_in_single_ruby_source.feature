Feature: Be testable in a single Ruby source

  In order to try Observed to see the basic usage usage of it,
  I want to configure and run Observed in just a single Ruby source file

  Scenario: Create a .rb file containing Observed code and run it with the ruby command
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

    observe 'foo', via: 'test'

    run 'foo'

    report /foo/, via: 'stdout'

    run 'foo'
    """
    When I run `ruby test.rb`
    Then the output should contain:
    """
    foo {:foo=>1}
    """
