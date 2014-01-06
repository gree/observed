require 'thread'
require 'observed/basic_event_bus'

module Observed
  class EventBus
    def initialize(args={})
      @bus = Observed::BasicEventBus.new
      @receives = {}
      @job_factory = args[:job_factory] || fail("The parameter :job_factory is missing in args(#{args}")
      @mutex = ::Mutex.new
    end
    def pipe_to_emit(tag)
      @job_factory.job { |*params|
        @bus.emit tag, *params
        params
      }
    end
    def emit(tag, *params)
      pipe_to_emit(tag)
    end
    def receive(pattern)
      job = @job_factory.mutable_job {|data, options|
        [data, options]
      }
      @bus.on_receive(pattern) do |*params|
        job.now(*params)
      end
      job
    end
  end
end
