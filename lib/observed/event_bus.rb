require 'thread'

module Observed
  class EventBus
    def initialize
      @mutex = ::Mutex.new
      @subscribers = []
    end
    def emit(tag, *params)
      handle_event(tag, *params)
    end

    def on_receive(pattern, &block)
      @mutex.synchronize do
        @subscribers.push [pattern, block]
      end
    end

    private

    def handle_event(tag, *params)
      @mutex.synchronize do
        @subscribers.each do |pattern, s|
          if pattern.match(tag)
            s.call *params
          end
        end
      end
    end
  end
end
