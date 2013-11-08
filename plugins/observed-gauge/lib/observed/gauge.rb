require 'observed/reporter'
require 'observed/reporter/regexp_matching'
require 'observed/gauge/version'
require 'logger'
require 'rrd'

module Observed
  module Plugins
    class Gauge < Observed::Reporter

      plugin_name 'gauge'

      include Observed::Reporter::RegexpMatching

      attribute :tag
      attribute :key_path
      attribute :coerce, default: ->(data){ data }
      attribute :rrd
      attribute :step
      attribute :period

      def report(tag, time, data)
        rewrote = update_value_for_key_path(data, key_path) do |v|
          sample = coerce.call(v)
          average = get_cdp_updated_with(time, sample)
          average
        end
        unless fetch_value_for_key_path(rewrote, key_path).nan?
          system.report(self.tag, rewrote)
        end
      end

      def prepare_rrd(args)
        start = args[:start]
        logger.debug "Creating a rrd file named '#{args[:rrd]}' with options {:start => #{start}}"
        result = RRD::Builder.new(args[:rrd], start: start, step: step.seconds).tap do |builder|
          builder.datasource data_source, :type => :gauge, :heartbeat => period.seconds, :min => 0, :max => :unlimited
          builder.archive :average, :every => period.seconds, :during => period.seconds
          builder.save
        end
        logger.debug "Builder#save returned: #{result.inspect}"
      end

      private

      def update_value_for_key_path(data, key_path, &block)
        first, *rest = split_key_path(key_path)
        data = data.dup
        dug_data = data[first] || data[first.intern]

        if rest.empty?
          hash_update(data, first, block.call(dug_data))
        else
          hash_update(data, first, update_value_for_key_path(dug_data, rest, &block))
        end

        data
      end

      def hash_update(hash, key, value)
        if hash[key]
          hash[key] = value
        else
          hash[key.intern] = value
        end
      end

      def fetch_value_for_key_path(data, key_path)
        first, *rest = split_key_path(key_path)
        dug_data = data[first] || data[first.intern]
        if rest.empty?
          dug_data
        else
          fetch_value_for_key_path(dug_data, rest)
        end
      end

      def split_key_path(key_path)
        case key_path
        when Array
          key_path
        when String
          key_path.split('.')
        else
          fail "Unexpected type of key_path met. Expected an Array or a String, but it was a(n) #{key_path.class}"
        end
      end

      def data_source
        self.key_path.gsub('.', '_')
      end

      # @param [Time] time
      def get_cdp_updated_with(time, value)
        rrd_path = self.rrd
        t = time.to_i

        rrd = RRD::Base.new(rrd_path)

        unless File.exist? rrd_path
          prepare_rrd(rrd: rrd_path, start: t)
        end

        logger.debug "Updating the data source '#{data_source}' with the value #{value} with timestamp #{t}"
        rrd.update t, value

        logger.debug rrd.fetch!(:average)[-2..-1]

        rrd.fetch(:average)[-2..-1].first.last
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
