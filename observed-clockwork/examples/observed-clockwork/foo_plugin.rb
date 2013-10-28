module OneshotSpec
  class FooPlugin < Observed::Plugin
    default :timeout_in_milliseconds => 5000
    default :number_of_trials => 10

    def run_health_check_once
      sleep_duration = rand / 20
      sleep sleep_duration
      "Foo #{sleep_duration}"
    end

    def logger
      Logger.new(STDOUT)
    end

    def self.plugin_name
      'foo'
    end
  end
end
