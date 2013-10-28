module Observed
  class InputPlugin
    class ObservationResult

      def initialize(args)
        @elapsed_time_in_milliseconds = args[:elapsed_time_in_milliseconds]
        @check_name = args[:check_name]
        @check_content = args[:check_content]
      end

      def elapsed_time_in_milliseconds
        @elapsed_time_in_milliseconds
      end

      def check_name
        @check_name
      end

      def check_content
        @check_content
      end

    end
  end
end
