require 'fakefs/spec_helpers'
require 'rspec'

require 'coveralls'
Coveralls.wear!

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

module Observed
  module SpecHelpers

    class << self

      def extended(example_group)
        #example_group.before do
        #  input_plugins = Observed::Observer.instance_variable_get(:@plugins) || []
        #  output_plugins = if Object.const_defined?(:Observed) && Observed.const_defined?(:Reporter)
        #                     Observed::Reporter.instance_variable_get(:@plugins) || []
        #                   else
        #                     []
        #                   end
        #  (input_plugins + output_plugins).each do |klass|
        #    Observed::SpecHelpers.undefine_const(klass)
        #  end
        #  Observed::Observer.instance_variable_set(:@plugins, [])
        #
        #  if Object.const_defined?(:Observed) && Observed.const_defined?(:Reporter)
        #    Observed::Reporter.instance_variable_set(:@plugins, [])
        #  end
        #end
      end

      def included(example_group)
        example_group.extend self
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

    end

  end
end
