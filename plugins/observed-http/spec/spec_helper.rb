require 'fakefs/spec_helpers'
require 'rspec'

Dir["#{File.expand_path('..',  __FILE__)}/support/**/*.rb"].each { |f| require f }

puts "Please do not update/create files while tests are running."

RSpec.configure do |config|
  config.color_enabled = true
  config.order = :random
  config.filter_run :focus => true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    @fixture_path = Pathname.new(File.expand_path('../fixtures/',  __FILE__))
  end

  config.mock_framework = :mocha
end

if RUBY_VERSION =~ /^1.9/
  require 'simplecov'
  SimpleCov.start
end
