require 'observed/configurable'
require 'observed/hash/fetcher'

module Observed
  class Reporter
    # The module to equip an observer with a `formatter` to format the data being reported.
    # The `formatter` is just a proc and is able to be configured via an attribute.
    #
    # @example
    # class YourObserver < Observed::Reporter
    #   include Observed::Reporter::Configurable
    #   include Observed::Reporter::FormattedReporting
    #
    #   attribute :format, default: -> tag, time, data { "#{Time.at(time)} #{tag} #{data}" }
    #
    #   def report(tag, time, data)
    #     # The output of your choice
    #   end
    #
    #   include Observed::Reporter::FormattedReporting
    # end
    #
    # observer = YourObserver.new(format: -> tag, time, data { "The data being reported: #{tag} #{time} #{data}" })
    # observer.report('test', Time.now, {data: 1})
    module ReportFormatting

      include Observed::Configurable

      attribute :format, default: -> tag, time, data { "#{Time.at(time)} #{tag} #{data}" }

      # Format the data being reported. The data includes 3 parameters: `tag`, `time` and `data`.
      # @param [String] tag
      # @param [Time] time
      # @param [Hash] data
      def format_report(tag, time, data)
        num_params = format.parameters.size
        case num_params
        when 3
          format.call(tag, time, data)
        when 4
          format.call(tag, time, data, Observed::Hash::Fetcher.new(data))
        else
          fail "Number of parameters for the function for the key :format must be 3 or 4, but was #{num_params}(#{format.parameters}"
        end
      end

    end
  end
end
