require 'observed/http/version'
require 'observed/observer_helpers/timer'
require 'timeout'
require 'net/http'

module Observed
  module Plugins
    class HTTP < Observed::Observer

      include Observed::ObserverHelpers::Timer

      attribute :timeout_in_milliseconds, default: 5000

      attribute :method
      attribute :url

      def observe
        logger.debug "method: #{method}, url: #{url}"

        uri = URI.parse(url)

        logger.debug "uri: #{uri}, uri.host: #{uri.host}, uri.port:#{uri.port}, uri.path: #{uri.path}"

        http_method = method.capitalize
        path = if uri.path.size == 0
                 '/'
               else
                 uri.path
               end
        req = Net::HTTP::const_get(http_method.intern).new(path)

        timeout_in_seconds = timeout_in_milliseconds / 1000.0
        if timeout_in_seconds.nan?
          fail "Invalid configuration on timeout: `timeout` must be a number but it was not(=#{timeout_in_seconds})"
        end

        time_and_report(tag: self.tag, timeout_in_seconds: timeout_in_seconds) do

          logger.debug "Sending a HTTP request with the timeout of #{timeout_in_seconds} seconds"

          body = Net::HTTP.start(uri.host, uri.port) {|http|
            http.request(req)
          }.body

          logger.debug "Response body: #{body}"

          "#{http_method} #{uri}"
        end

      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      plugin_name 'http'

    end
  end
end
