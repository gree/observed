module Observed
  module InputHelpers
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
        rescue Timeout::Error => e1
          { status: :error, error: {message: "#{e2.message}\n#{e2.backtrace}"}, timed_out: true }
        rescue => e2
          { status: :error, error: {message: "#{e2.message}\n#{e2.backtrace}"} }
        end
      end

      def time_and_emit(options={}, &block)
        tag = options[:tag] || (self.respond_to?(:tag) && self.tag) || fail("The key `:tag` must be exist in the options: #{options}")
        format = options[:format] || ->(r){ r }
        result = time(options, &block)

        system.emit("#{tag}.#{result[:status]}", format.call(result))
      end

    end
  end
end
