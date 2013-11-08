require 'observed/fluentd/version'
require 'observed/reporter'
require 'observed/reporter/regexp_matching'
require 'fluent-logger'

module Observed
  module Plugins
    class Fluentd < Observed::Reporter

      include Observed::Reporter::RegexpMatching

      plugin_name 'fluentd'

      attribute :tag
      attribute :host
      attribute :port, default: 24224
      attribute :transform, default: ->(data){ data }

      def report(tag, time, data)
        fluent_logger.post(self.tag, transform.call(data))
      end

      private

      def fluent_logger
        @fluent_logger ||= Fluent::Logger::FluentLogger.new(nil, host: host, port: port)
      end
    end
  end
end
