require 'observed/hash/fetcher'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'
require 'observed/reporter/report_formatting'

module Observed
  module BuiltinPlugins
    class File < Observed::Reporter

      include Observed::Reporter::RegexpMatching
      include Observed::Reporter::ReportFormatting

      UNDEFINED = Object.new

      attribute :path
      attribute :mode, default: :append

      # @param [String] tag
      # @param [Time] time
      # @param [Hash] data
      def report(tag, time, data)
        formatted_data = format_report(tag, time, data)
        mode = case self.mode
               when :append, 'a'
                 'a'
               when :overwrite, 'w'
                 'w'
               else
                 fail "Unsupported value for the parameter `:mode`: Supported values are :append, :overwrite, " +
                          "'a', 'w'. The specified value is #{self.mode.inspect}"
               end
        ::File.open(path, mode) do |f|
          f.puts formatted_data
        end
      end

      plugin_name 'file'
    end
  end
end
