Feature: Receives Observed's input and send it to Fluentd

  In order to pass data from Observed to Fluentd

  I want to configure Observed to use observed-fluentd plugin

  Scenario: Write configuration files for Observed and Fluentd, then run Fluentd, and then run Observed
    Given a file named "test.rb" with:
    """
    require 'observed'
    require 'observed/http'
    require 'observed/fluentd'

    include Observed

    observe 'myservice', via: 'http', with: {
      method: 'get',
      url: 'http://google.com/',
      timeout_in_milliseconds: 3000,
    }

    report /myservice.*/, via: 'fluentd', with: {
      host: 'localhost',
      port: 24224,
      tag: 'debug.myservice'
    }

    run 'myservice'
    """
    Given a file named "fluent.conf" with:
    """
    <source>
      type forward
    </source>

    <match debug.**>
      type file
      path tmp/aruba/fluent.out
      time_slice_format foo
      utc
      flush_interval 1s
    </match>
    """
    When I run `pwd`
    When I start my daemon with "fluentd -c tmp/aruba/fluent.conf"
    When I run `sleep 3`
    When I run `ruby test.rb`
    Then a daemon called "fluentd" should be running
    When I run `sleep 3`
    When I run `cat fluent.out.foo_0.log`
    Then the output should contain:
    """
    elapsed_time
    """
    Then the output should contain:
    """
    debug.myservice
    """

