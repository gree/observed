module OneshotSpec
  class FooPlugin < Observed::InputPlugin
    default :timeout_in_milliseconds => 5000
    default :number_of_trials => 10

    def observe
      sleep_duration = rand / 20
      sleep sleep_duration
      system.emit(tag, now, "Foo #{sleep_duration}")
    end

    def logger
      Logger.new(STDOUT)
    end

    def self.plugin_name
      'foo'
    end
  end
end
