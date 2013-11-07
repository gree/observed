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

      def undefine_const(klass)
        klass_name = klass.to_s
        md = klass_name.match(/(.+)::([^:]+)/)
        if md
          Observed::SpecHelpers.logger.debug "Removing the const #{md[2]} in #{md[1]}"
          enclosing_module_name, klass_name = md[1..2]
          enclosing_module = eval enclosing_module_name
        else
          enclosing_module = Object
        end
        enclosing_module.send(:remove_const, klass_name.intern)
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

    end

    def define_input_plugin(class_name, &block)
      Object.const_set(
        class_name,
        Class.new(Observed::Observer) do
          instance_eval &block
        end
      )
    end

    def define_output_plugin(class_name, &block)
      Object.const_set(
        class_name,
        Class.new(Observed::Reporter) do
          instance_eval &block
        end
      )
    end
  end
end
