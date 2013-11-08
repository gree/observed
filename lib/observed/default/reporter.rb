require 'observed/reporter'
require 'observed/reporter/regexp_matching'

module Observed
  module Default
    class Reporter < Observed::Reporter
      include Observed::Reporter::RegexpMatching

      attribute :writer

      def report(tag, time, data)
        writer.write tag, time, data
      end

    end
  end
end
