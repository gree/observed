# Observed

Observed is a framework for polling various applications/middlewares/services running locally or on remote servers like
ones in your production environment.

Observed polls services, optionally transforms the results, and then redirects the results to another services.
Observed is open for extension which means that it is extensible via plugins to support add more services and transformations.

There are known plugins for:

- Polling HTTP-based services to detect failures and performance degradation
- (More to come)

Observed is intended to work on Ruby 1.9.3 but should work on Ruby 2.0+ too.

## Installation

Add this line to your application's Gemfile:

    gem 'observed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observed

## Usage

    $ gem install observed
    $ gem install observed-clockwork
    $ gem install observed-http

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

    Run:

    ```
    $ clockwork clockwork.rb
    ```

    Then you see turn-around-time and status(`success` or `error`) for each poll to your HTTP service running on
    `http://localhost:3000`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
