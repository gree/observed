require 'observed/hash/fetcher'
require 'observed/observer'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'
require 'observed/reporter/report_formatting'

module Observed
  module BuiltinPlugins
    class Stdout < Observed::Reporter

      include Observed::Reporter::RegexpMatching
      include Observed::Reporter::ReportFormatting

      attribute :output, default: STDOUT

      # @param [String] tag
      # @param [Time] time
      # @param [Hash] data
      # @param [Object] format_result
      def report(tag, time, data)
        formatted_data = format_report(tag, time, data)
        output.puts formatted_data
      end

      plugin_name 'stdout'
    end
  end
end
