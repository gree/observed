require 'rspec'

puts "Please do not update/create files while tests are running."

RSpec.configure do |config|
  config.color_enabled = true
  config.order = :random
  config.filter_run :focus => true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.mock_framework = :mocha
end

if RUBY_VERSION =~ /^1.9/
  require 'simplecov'
  SimpleCov.start
end
