require 'observed/hash/fetcher'
require 'observed/observer'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'

module Observed
  module BuiltinPlugins
    class Stdout < Observed::Reporter

      include Observed::Reporter::RegexpMatching

      attribute :format, default: -> tag, time, data { "#{Time.at(time)} #{tag} #{data}" }
      attribute :output, default: STDOUT

      # @param [String] tag
      # @param [Time] time
      # @param [Hash] data
      def report(tag, time, data)
        num_params = format.parameters.size
        formatted_data = case num_params
        when 3
          format.call(tag, time, data)
        when 4
          format.call(tag, time, data, Observed::Hash::Fetcher.new(data))
        else
          fail "Number of parameters for the function for the key :format must be 3 or 4, but was #{num_params}(#{format.parameters}"
        end
        output.puts formatted_data
      end

      def self.plugin_name
        'stdout'
      end
    end
  end
end
