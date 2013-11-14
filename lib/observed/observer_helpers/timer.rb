module Observed
  module ObserverHelpers
    module Timer

      require 'timeout'

      def time(options={}, &block)
        timeout_in_seconds = options[:timeout_in_seconds] ||
            fail("The key `:timeout_in_seconds` must be exist in the options: #{options}")

        begin
          before = system.now
          r = Timeout::timeout(timeout_in_seconds) do
            { status: :success, result: block.call }
          end
          after = system.now
          elapsed_time = after - before
          r[:elapsed_time] = elapsed_time
          r
        rescue Timeout::Error => e
          log_debug "Handled the error but logging it just for your info: #{e.message}\n#{e.backtrace.join("\n")}" if self.is_a? Logging
          { status: :error, error: {message: 'Timed out.'}, timed_out: true }
        rescue => e
          log_error "Handled the error: #{e.message}\n#{e.backtrace.join("\n")}" if self.is_a? Logging
          { status: :error, error: {message: e.message} }
        end
      end

      def time_and_report(options={}, &block)
        tag = options[:tag] || (self.respond_to?(:tag) && self.tag) || fail("The key `:tag` must be exist in the options: #{options}")
        format = options[:format] || ->(r){ r }
        result = time(options, &block)

        data = ["#{tag}.#{result[:status]}", format.call(result)]

        if self.method(:observe).parameters.size != 1
          system.report(*data)
        end

        data
      end

    end
  end
end
