require 'thread'
require 'observed/basic_event_bus'

module Observed
  class EventBus
    def initialize(args={})
      @bus = Observed::BasicEventBus.new
      @receives = {}
      @task_factory = args[:task_factory] || fail("The parameter :task_factory is missing in args(#{args}")
      @mutex = ::Mutex.new
    end
    def emit(tag, *params)
      @task_factory.task { |*params|
        @bus.emit tag, *params
        params
      }
    end
    def receive(pattern)
      task = @task_factory.mutable_task {|data, options|
        [data, options]
      }
      @bus.on_receive(pattern) do |*params|
        task.now(*params)
      end
      task
    end
  end
end
