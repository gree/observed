# Observed

[![Build Status](https://travis-ci.org/gree/observed.png?branch=master)](https://travis-ci.org/gree/observed) [![Coverage Status](https://coveralls.io/repos/gree/observed/badge.png?branch=master)](https://coveralls.io/r/gree/observed?branch=master) [![Code Climate](https://codeclimate.com/github/gree/observed.png)](https://codeclimate.com/github/gree/observed)

Observed is a highly extensible framework for polling applications, middlewares and services running locally or on remote servers.

-----

Observed allows you to:

1.  poll server(s),
2.  optionally modify the response result,
3.  pass the result on to other services or trigger other tasks

All the above 3 operations are extensible via plugins and can be configured via configuration files.

There are plugins available for:

-  Polling HTTP-based services to detect failures and performance degradation
-  Sending observed data to Fluentd

Additional plugins will be released in the future.

Observed has has a very small code-base (only a few hundred lines) which makes reading and understanding it's source code and developing plugins for it a relatively simple task.

Observed's extensible design through plugins is inspired by other Ruby projects such as Fluentd. People familiar with other Ruby products should feel right at home with Observed. As of now it is a highly ambitious and experimental framework with big potential for growth and improvements.

Observed is (and its plugins should be) stateless.
This means that it should work in the same manner whether it is run as a daemon or a _oneshot_ application like
a regular cron job, as states should be stored outside of the application instance with regards to Observed.

Observed is intended to be run on Ruby 1.9.3 but should work on Ruby 2.0+ too.

## Observed is not:
-  a monitoring and reporting tool such as New Relic etc. However, Observed can be used for collecting simple metrics via plugins, then pass them on to another full-fledged monitoring or reporting tool.
-  a log collector like Fluentd. Observed can be used to emit event logs to the log collector of your choice, but it does not replace the log collector.
-  a [job scheduler](http://en.wikipedia.org/wiki/Job_scheduler) (e.g. cron), though it can be integrated with job schedulers to make them trigger Observed to perform jobs.

## Similar products

- [vacuumetrix](https://github.com/99designs/vacuumetrix) - Collects metrics from various sources and outputs them to various destinations (e.g Graphite). Observed only covers the `polling` part, but can output to not just monitoring systems but any system.
- [metrics-sampler](https://github.com/dimovelev/metrics-sampler) - A Java program which queries metrics from various sources and outputs to various destinations such as Graphite or consoles. It supports various methods of input such as JMX, JDBC, apache-status, Oracle NoSQL, Redis, web API, or regular processes which are executable via the command-line, and is able to communicate via standard input/output.

## Installation

Add this line to your application's Gemfile:

    gem 'observed'

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install observed

Or `git clone` the sources and install by using rake:

    $ rake install

## Usage

Simple example: _use Observed to observe and report the healthiness of Google_.

Assume that we want Observed to poll a HTTP-based web service (Google) and report the results.

Since Observed by itself is just a framework and by default does not have built-in support for any service, we start by installing some Observed plugins:

    $ gem install observed
    $ gem install observed-clockwork
    $ gem install observed-http

For this example, we will use observed-clockwork to trigger polls through [Clockwork](https://github.com/tomykaira/clockwork).

observed-clockwork is a library to be used with Clockwork's configuration file. Clockwork is a cron replacement for a scheduler process that is written in Ruby.

Note that we can also use cron, which is supported via observed-cron plugin (even without the plugin it is really simple to use Observed with cron) but we will use Clockwork for this example.

Edit the contents of `clockwork.rb`:

```ruby
require 'pathname'

require 'clockwork'
require 'observed/clockwork'

include Clockwork

the_dir = Pathname.new(File.dirname(__FILE__))

# The following two lines are specific to Observed's Clockwork support.
include Observed::Clockwork

register_observed_handler :config_file => the_dir + 'observed.rb'

every(10.seconds, 'google.health')
```

Edit the contents of `observed.rb` as follows:

```ruby
require 'observed/http'

observe 'google.health', via: 'http', with: {
    method: 'get',
    url: 'http://www.google.co.jp/'
}

report /google.health/, via: 'stdout', with: {
    format: -> tag, time, data {
      case data[:status]
      when :success
        'Google is healthy! (^o^)'
      else
        'Google is unhealthy! (;_;)'
      end
    }
}
```

As you see, `observed.rb` is just a Ruby source file that describes Observed's configuration.
You can use Ruby language's features, gems, etc.

That sums up the configuration part of things.

Now, run:

```
$ clockwork clockwork.rb

I, [2013-11-08T23:39:53.999484 #44285]  INFO -- : Starting clock for 1 events: [ google.health ]
I, [2013-11-08T23:39:53.999555 #44285]  INFO -- : Triggering 'google.health'
Google is healthy! (^o^)
Google is healthy! (^o^)
Google is healthy! (^o^)
...
```

And we're done! That's all it takes to print Google's health to standard output every 10 seconds with Observed.

The example described here is fairly simple and may look useless at first glance, but keep in mind that Observed is just a framework.

If you want to monitor performance or get statistics on performance on your service, you can redirect the results to Fluentd or other service to take advantage of their features and plugins.

We prefer to not reinvent the wheel and encourage people to use Observed for polling and output results to other services for other tasks like monitoring or alerts.

## Documentation

Observed is documented with [YARD](https://github.com/lsegal/yard).

The latest documentation for the master branch of Observed [is available at rubydoc.info](http://rubydoc.info/github/gree/observed).

You can also generate the document locally.
To do so, install YARD:

```
$ gem install yard
```

And then run `yardoc` as follows:

```
$ yardoc 'lib/**/*.rb'
```

You can then open the generated documentation:

```
$ open doc/index.html
```

## Contributing

1.  [Fork it](https://github.com/gree/observed)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new pull request
