require 'thread'
require 'monitor'

module Observed
  class EventBus
    def initialize
      @monitor = ::Monitor.new
      @subscribers = []
    end
    def emit(tag, *params)
      handle_event(tag, *params)
    end

    def on_receive(pattern, &block)
      @monitor.synchronize do
        @subscribers.push [pattern, block]
      end
    end

    private

    def handle_event(tag, *params)
      @monitor.synchronize do
        @subscribers.each do |pattern, s|
          if pattern.match(tag)
            s.call *params
          end
        end
      end
    end
  end
end
