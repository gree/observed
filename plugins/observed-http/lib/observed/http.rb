require "observed/http/version"

module Observed
  module Plugins
    class HTTP < Observed::Plugin

      default :timeout_in_milliseconds => 5000
      default :number_of_trials => 10

      attribute :method
      attribute :url

      def run_health_check_once
        logger.debug "method: #{method}, url: #{url}"
        require 'net/http'
        uri = URI.parse(url)
        logger.debug "uri: #{uri}, uri.host: #{uri.host}, uri.port:#{uri.port}, uri.path: #{uri.path}"
        http_method = method.capitalize
        path = if uri.path.size == 0
                 '/'
               else
                 uri.path
               end
        req = Net::HTTP::const_get(http_method.intern).new(path)
        body = Net::HTTP.start(uri.host, uri.port) {|http|
          http.request(req)
        }.body
        logger.debug "Response body: #{body}"
        "#{http_method} #{uri}"
      end

      def logger
        Logger.new(STDOUT)
      end

      def self.plugin_name
        'http'
      end

    end
  end
end
