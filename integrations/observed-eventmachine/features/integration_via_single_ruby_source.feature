Feature: Integration via single Ruby source

  In order to easily integrate Observed with EventMachine,
  I want to extend Observed's DSL with words specific to the EventMachine integration,
  and make it runnable and testable in single Ruby source.

  Scenario: Create a .rb file containing Observed code and run it with the ruby command
    Given a file named "test.rb" with:
    """
    require 'observed'
    require 'observed/eventmachine'

    include Observed

    extend Observed::EM

    $count = 0

    class Test < Observed::Observer
      plugin_name 'test'
      def observe
        $count += 1
        system.report(tag, {foo:1})
        if $count >= 2
          exit
        end
      end
    end

    observe 'foo', via: 'test'

    report /foo/, via: 'stdout', with: {
      format: -> tag, _, data { "#{tag} #{$count} #{data}" }
    }

    every 1, run: 'foo'

    start
    """
    When I run `ruby test.rb`
    Then the output should contain:
    """
    foo 1 {:foo=>1}
    foo 2 {:foo=>1}
    """
