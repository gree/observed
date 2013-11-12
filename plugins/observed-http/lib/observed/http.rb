require 'observed/http/version'
require 'observed/observer'
require 'observed/observer_helpers/timer'
require 'observed/logging'
require 'timeout'
require 'net/http'

module Observed
  module Plugins
    class HTTP < Observed::Observer

      include Observed::ObserverHelpers::Timer
      include Observed::Logging

      attribute :timeout_in_milliseconds, default: 5000

      attribute :method
      attribute :url
      attribute :logger

      def observe
        log_debug "method: #{method}, url: #{url}"

        uri = URI.parse(url)

        log_debug "uri: #{uri}, uri.host: #{uri.host}, uri.port:#{uri.port}, uri.path: #{uri.path}"

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

          log_debug "Sending a HTTP request with the timeout of #{timeout_in_seconds} seconds"

          body = Net::HTTP.start(uri.host, uri.port) {|http|
            http.request(req)
          }.body

          log_debug "Response body: #{body}"

          "#{http_method} #{uri}"
        end

      end

      plugin_name 'http'

    end
  end
end
