require 'observed/input_plugin'
require 'observed/output_plugin'

module Observed
  module BuiltinPlugins
    class Stdout < Observed::OutputPlugin
      # @param [String] tag
      # @param [Fixnum] time
      # @param [Observed::Data] data
      def emit(tag, time, data)
        puts "#{Time.at(time)} #{tag} #{data}"
      end

      def self.plugin_name
        'stdout'
      end
    end
  end
end
