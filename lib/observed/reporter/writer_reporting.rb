require 'observed/configurable'

module Observed
  class Reporter
    module WriterReporting

      include Observed::Configurable

      attribute :writer

      def report(tag, time, data)
        writer.write tag, time, data
      end

    end
  end
end
