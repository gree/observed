# [Observed](https://github.com/gree/observed)

[![Build Status](https://travis-ci.org/gree/observed.png?branch=master)](https://travis-ci.org/gree/observed) [![Coverage Status](https://coveralls.io/repos/gree/observed/badge.png?branch=master)](https://coveralls.io/r/gree/observed?branch=master) [![Code Climate](https://codeclimate.com/github/gree/observed.png)](https://codeclimate.com/github/gree/observed)

A polling framework

[Observed](https://github.com/gree/observed) is a framework for polling various applications/middlewares/services running locally or on remote servers like
ones in your production environment.
It is designed with extensibility in mind.

-----

Observed polls services, optionally transforms the results, and then redirects the results to another services.
Observed is open for extension which means that it is extensible via plugins to support add more services and transformations.

To be clear, you can use Observed to:

1.  poll something,
2.  optionally transform the result,
3.  pass the result to another services or trigger something

All the three things mentioned above can be extended via plugins and configured via configuration files.

There are known plugins for:

-  Polling HTTP-based services to detect failures and performance degradation
-  Sending observed data to Fluentd
-  (More to come)

Observed has has a very small code-base (only a few hundreds of lines) and it should not be too hard to understand the
code and develop plugins.

Observed's extensible design through plugins is inspired by other Ruby products like Fluentd,
and having knowledge of other Ruby products may help understanding Observed.
(But remember that Observed is yet a highly ambitioned and experimental framework. Observed's code has more space to
improve than other great Ruby products.)

Observed is (and its plugins should be) stateless.
Specially for Observed, this means that it should work similarly when it is ran as a daemon or a _oneshot_ application like
a regular cron job as states are stored somewhere outside of the application instance.

Observed is intended to work on Ruby 1.9.3 but should work on Ruby 2.0+ too.

## What it is not

Observed is:

-  Not a framework for creating Web-based polls which are voted. It's all about [polling (computer science)](http://en.wikipedia.org/wiki/Polling_\(computer_science\))
-  Not a monitoring and reporting tool like Ganglia, New Relic, or etc.
   But Observed can be used to gather simple metrics via its plugins, and it can pass those metrics to an another tool to
   achieve any serious monitoring or reporting.
-  Not a log collector like Fluentd.
   Observed can be used to emit event logs to the log collector of your choice, but it does not replace or act like that.
-  Not a [job scheduler](http://en.wikipedia.org/wiki/Job_scheduler) like cron, though it can be integrated to those schedulers to make them trigger Observed to do the
   job.

## Similar products

- [vacuumetrix](https://github.com/99designs/vacuumetrix) gets metrics from various sources and puts those to various
  outputs like Graphite, Ganglia, etc.
  On the other hand, Observed scope itself to be used just for `polling` and also it outputs to not only monitoring
  systems but any system.
- [metrics-sampler](https://github.com/dimovelev/metrics-sampler) is a java program which queries metrics from various
  sources and sends them to outputs like the console or Graphite. It supports inputs such as JMX, JDBC, apache-status,
  Oracle NoSQL, Redis, webmethods, or regular process which is runnable via the command-line and is able to communiate
  via standard input/output.

## Installation

Add this line to your application's Gemfile:

    gem 'observed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observed

Or `git clone` the sources and install by using rake:

    $ rake install

## Usage

Just for the purpose of illustration, _let Observed observe and report the healthiness of Google_.

Observed itself is just a framework and doesn't support any service by default.
Now, just for example, let's assume that we want Observed to poll our HTTP-based webs service and report the result and
show average response time.
We start with installing some observed plugins:

    $ gem install observed
    $ gem install observed-clockwork
    $ gem install observed-http

In this case, we use observed-clockwork to trigger polls through [Clockwork](https://github.com/tomykaira/clockwork).
observed-clockwork is a library intended to use in Clockwork's configuration
file. Clockwork is a scheduler process made with Ruby, which is intended to replace cron.
Note that we can just use cron which is supported via observed-cron plugin(or even without the plugin, it is breeze to use
Observed with cron) but we proceed with Clockwork just for example.

With `clockwork.rb` like:

```ruby
require 'pathname'

require 'clockwork'
require 'observed/clockwork'

include Clockwork

# Below two lines are specific to Observed's Clockwork support.
# Others lines are just standard `clockwork.rb`
include Observed::Clockwork

the_dir = Pathname.new(File.dirname(__FILE__))

register_observed_handler :config_file => the_dir + 'observed.rb'

every(10.seconds, 'google.health')
```

With `observed.rb` like:

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

As you see, `observed.conf` is just a Ruby source to describe Observed's configuration.
You can rely on Ruby's language features, gems, or etc.

We have finished configuring Observed.

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

You did it!
You just saw that Google's healthiness is printed to the standard output every 10 seconds.
In other words, you did observed Google's healthiness with easily with Observed.

The example described here is fairly simple and would look useless at a glance, but remember that Observed is just a
framework.
If you want to monitor performances or get statistics on performance on your service, you can redirect the results to
Fluentd, Ganglia or else and take advantages of their rich features and plugins.
We like not reinventing the wheel and it is encouraged to use Observed for just to poll something and then emit the
result to other services. Things like monitoring, watching, alerting can be done there.

## Documentation

Observed is documented with [YARD](https://github.com/lsegal/yard).

The latest documentation for the master branch of Observed [is available at rubydoc.info](http://rubydoc.info/github/gree/observed).

You can also generate the document locally.
To do that, install YARD:

```
$ gem install yard
```

And then run `yardoc` like:

```
$ yardoc 'lib/**/*.rb'
```

Open the document:

```
$ open doc/index.html
```

## Contributing

1.  [Fork it](https://github.com/gree/observed)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
