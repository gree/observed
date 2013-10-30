module Observed
  module InputHelpers
    module Timer

      def observe
        before = Time.now
        result = begin
          try
        rescue => e
          { status: :error, message: "#{e.message}\n#{e.backtrace}" }
        end
        after = Time.now
        elapsed_time = after - before
        system.emit("#{tag}.#{result[:status]}", Time.now, "#{result[:message]} finished in #{elapsed_time} milliseconds.")
      end

      def try
        fail 'Not Implemented'
      end

    end
  end
end
