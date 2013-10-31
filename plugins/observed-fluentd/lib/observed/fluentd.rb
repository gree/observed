require 'observed/fluentd/version'
require 'observed/output_plugin'
require 'fluent-logger'

module Observed
  module Plugins
    class Fluentd < Observed::OutputPlugin
      attribute :tag
      attribute :host
      attribute :port, default: 24224
      attribute :transform, default: ->(data){ {data: data} }

      def emit(tag, time, data)
        fluent_logger.post(self.tag, transform.call(data))
      end

      def self.plugin_name
        'fluentd'
      end

      private

      def fluent_logger
        @fluent_logger ||= Fluent::Logger::FluentLogger.new(nil, host: host, port: port)
      end
    end
  end
end
