# observed-clockwork

observed-clockwork is an integration of Observed and Clockwork.
In the integration, we can define jobs in Observed and schedule those to run by Clockwork.

## Installation

Add this line to your application's Gemfile:

    gem 'observed-clockwork'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install observed-clockwork

## Usage

### With Bundler

    $ bundle install
    $ bundle exec clockwork examples/clockwork/clockwork.rb

    Or with daemonizing:

    $ bundle install (Note that we need to add the dependency to 'daemons' gem in our Gemfile or gemspec)
    $ bundle exec clockworkd -c examples/clockwork/clockwork.rb -l start
    $ tail -f tmp/clockworkd.clockwork.output
    $ bundle exec clockworkd -c examples/clockwork/clockwork.rb -l stop

### Without Bundler

    $ gem install observed-clockwork
    $ clockwork clockwork.rb

    Or with daemonizing:

    $ gem install observed-clockwork
    $ gem install daemons
    $ clockworkd -c examples/clockwork/clockwork.rb -l start
    $ tail -f tmp/clockworkd.clockwork.output
    $ clockworkd -c examples/clockwork/clockwork.rb -l stop

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
