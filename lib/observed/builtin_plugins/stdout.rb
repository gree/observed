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

    module Timer

      def observe
        before = Time.now
        result = begin
          try
        rescue => e
          { :status => :error, :message => e.message + "\n" + e.backtrace }
        end
        after = Time.now
        elapsed_time = after - before
        system.emit("#{tag}.#{result[:status]}", Time.now, "#{result[:message]} finished in #{elapsed_time} milliseconds.")
      end

      def try
        fail 'Not Implemented'
      end

    end
  end
end
