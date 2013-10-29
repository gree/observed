require "observed/http/version"
require "observed/input_helpers/timer"

module Observed
  module Plugins
    class HTTP < Observed::InputPlugin

      include Observed::InputHelpers::Timer

      default :timeout_in_milliseconds => 5000

      attribute :method
      attribute :url

      def try
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
        { :status => 'success', :message => "#{http_method} #{uri}" }
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
