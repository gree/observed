module OneshotSpec
  class FooPlugin < Observed::Observer

    plugin_name 'foo'

    default timeout_in_milliseconds: 5000
    default number_of_trials: 10

    def observe
      sleep_duration = rand / 20
      sleep sleep_duration
      system.report(tag, "Foo #{sleep_duration}")
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
