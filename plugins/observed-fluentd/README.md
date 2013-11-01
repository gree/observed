# Observed::Fluentd

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'observed-fluentd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observed-fluentd

## Usage

First of all, we need to install the fluentd to which we send observed data:

    $ gem install fluentd

Then we should configure Fluentd to see data which will be sent from observed-fluentd:

    $ fluentd --setup fluent.d
    Installed fluent.d/fluent.conf.

Ensure that the following 2 parts exist in the generated fluent.conf:

     <source>
       type forward
     </source>

    <match debug.**>
      type stdout
    </match>

Now we can run Fluentd:

    $ fluentd -c fluent.d/fluent.conf

Install observed-fluentd:

    $ gem build observed-fluentd.gemspec
    $ gem install observed-fluentd
    $ gem install observed-http
    $ gem install observed-clockwork

Create the observed.conf like:

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

Run clockwork and trigger observed:

    $ cd observe.d/
    $ clockwork clockwork.rb

Find data sent from Observed in the Fluentd output:

    2013-11-01T07:55:09Z	debug.myservice	{"status":"success","result":"Get http://localhost/","elapsed_time":0.013686}

Now you can do anything utilizing Fluent's rich features and plugins.

## Developping

To run cucumber tests, execute:

   $ bundle install --binstubs
   $ bin/cucumber features

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
