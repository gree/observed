# Observed

Observed is a framework for polling various applications/middlewares/services running locally or on remote servers like
ones in your production environment.

Observed polls services, optionally transforms the results, and then redirects the results to another services.
Observed is open for extension which means that it is extensible via plugins to support add more services and transformations.

There are known plugins for:

- Polling HTTP-based services to detect failures and performance degradation
- (More to come)

Observed has has a very small code-base (only a few hundreds of lines) and it should not be too hard to understand the
code and develop plugins.

Observed's extensible design through plugins is inspired by other Ruby products like Fluentd,
and having knowledge of other Ruby products may help understanding Observed.
(But remember that Observed is yet a highly ambitioned and experimental framework. Observed's code has more space to
improve than other great Ruby products.)

Observed is intended to work on Ruby 1.9.3 but should work on Ruby 2.0+ too.

## Installation

Add this line to your application's Gemfile:

    gem 'observed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observed

## Usage

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
require 'clockwork'
require 'observed/clockwork'

include Clockwork

# Below two lines are specific to Observed's Clockwork support.
# Others lines are just standard `clockwork.rb`
include Observed::Clockwork
observed :config_file => 'observed.conf'

every(10.seconds, 'foo_1')
```

With `observed.conf` like:

```ruby
require 'observed/builtin_plugins'
require 'observed/http'

observe 'myservice.http', {
  plugin: 'http'
  method: 'get',
  url: 'http://localhost:3000',
  timeout_in_milliseconds: 1000
}

match /myservice\..+/, plugin: 'stdout'

match /myservice\.http/, plugin: 'builtin_avg', tag: 'myservice.http.avg', time_window: 60 * 1000
match /myservice\.http\.avg/, plugin: 'stdout'
```

As you see, `observed.conf` is just a Ruby source to describe Observed's configuration.
You can rely on Ruby's language features, gems, or etc.

We have finished configuring Observed.

Now, run:

```
$ clockwork clockwork.rb
```

Then you will see turn-around-time and status(`success` or `error`) for each poll to your HTTP service running on
`http://localhost:3000`.

The example described here is fairly simple and would looks useless itself, but refrain that Observed is just a
framework.
If you want to monitor performances or get statistics on performance on your service, you can redirect the results to
Fluentd, Ganglia and take advantages of their rich features and plugins.
We like not reinventing the wheel and it is encouraged to use Observed for just polling, transforming and emitting the
result to other services, and do monitoring, watching, alerting things there.

## Documentation

Observed is documented with [YARD](https://github.com/lsegal/yard).
The documentation is not currently hosted on any server and we have to build the document before reading it.

To generate the document, install YARD:

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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
