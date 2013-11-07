module OneshotSpec
  class FooPlugin < Observed::Observer

    def observe
      sleep_duration = rand / 20
      sleep sleep_duration
      system.report(tag, system.now, "Foo #{sleep_duration}")
    end

    def self.plugin_name
      'foo'
    end
  end
end
