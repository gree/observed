module OneshotSpec
  class FooPlugin < Observed::InputPlugin

    def observe
      sleep_duration = rand / 20
      sleep sleep_duration
      system.emit(tag, now, "Foo #{sleep_duration}")
    end

    def self.plugin_name
      'foo'
    end
  end
end
