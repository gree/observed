Feature: Observe Web services via HTTP

  In order to observe Web services using Observed,
  I want to the observed-http plugin to send HTTP request and report the result via reporters

  Scenario: Create a .rb file containing Observed code and run it with the ruby command
    Given a file named "test.rb" with:
    """
    require 'observed'
    require 'observed/http'

    include Observed

    observe 'foo_1', via: 'http', with: {
      method: 'get',
      url: 'http://google.com',
      timeout_in_milliseconds: 1000
    }

    report /foo_\d+/, via: 'stdout'

    run 'foo_1'
    """
    When I run `ruby test.rb`
    Then the output should contain:
    """
    foo_1.success
    """
    Then the output should contain:
    """
    Get http://google.com
    """
