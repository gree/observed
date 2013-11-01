Feature: Receives Observed's input and send it to Fluentd

  In order to pass data from Observed to Fluentd

  I want to configure Observed to use observed-fluentd plugin

  Scenario: Send data to fluentd periodically
    Given a file named "observed.conf" with:
    """
    require 'observed/builtin_plugins'
    require 'observed/http'
    require 'observed/fluentd'

    observe 'myservice', {
      plugin: 'http',
      method: 'get',
      url: 'http://localhost/',
      timeout_in_milliseconds: 3000,
    }

    match /myservice.*/, {
      plugin: 'fluentd',
      host: 'localhost',
      port: 24224,
      tag: 'debug.myservice'
    }
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
    Given a file named "clockwork.rb" with:
    """
    require 'clockwork'
    require 'observed/clockwork'

    include Clockwork
    include Observed::Clockwork

    observed :config_file => 'tmp/aruba/observed.conf'

    every(1.seconds, 'myservice')
    """
    When I run `pwd`
    When I start my daemon with "fluentd -c tmp/aruba/fluent.conf"
    When I start my daemon with "clockwork tmp/aruba/clockwork.rb"
    Then a daemon called "fluentd" should be running
    Then a daemon called "clockwork" should be running
    When I run `cat fluent.out.foo_0.log`
    Then the output should contain:
    """
    elapsed_time
    """
