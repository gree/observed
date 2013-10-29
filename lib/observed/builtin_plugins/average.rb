require 'observed/output_plugin'
require 'observed/output_helpers/average'

module Observed
  module BuiltinPlugins
    class Average < Observed::OutputPlugin

      include Observed::OutputHelpers::Average

      def self.plugin_name
        'builtin_avg'
      end

    end
  end
end
