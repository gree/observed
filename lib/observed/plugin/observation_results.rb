require 'forwardable'

module Observed
  class Plugin
    class ObservationResults

      extend Forwardable

      def initialize(check_results)
        @check_results = check_results
      end

      def average_elapsed_time
        sum = @check_results.inject(0.0) { |sum, r| sum + r.elapsed_time_in_milliseconds }
        sum / @check_results.size
      end

      def to_s
        @check_results.to_s
      end

      def inspect
        @check_results.inspect
      end

      def each(&block)
        @check_results.each(&block)
      end

    end
  end
end
