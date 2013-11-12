module Observed
  class Reporter
    module WriterReporting

      def report(tag, time, data)
        writer.write tag, time, data
      end

    end
  end
end
