require 'observed/observer'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'

module Observed
  module BuiltinPlugins
    class Stdout < Observed::Reporter

      include Observed::Reporter::RegexpMatching

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
