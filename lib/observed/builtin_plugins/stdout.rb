require 'observed/observer'
require 'observed/reporter'

module Observed
  module BuiltinPlugins
    class Stdout < Observed::Reporter
      # @param [String] tag
      # @param [Fixnum] time
      # @param [Observed::Data] data
      def report(tag, time, data)
        puts "#{Time.at(time)} #{tag} #{data}"
      end

      def self.plugin_name
        'stdout'
      end
    end
  end
end
