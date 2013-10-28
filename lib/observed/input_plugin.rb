require 'observed/pluggable'
require 'observed/configurable'
require 'observed/plugin/observation_result'
require 'observed/plugin/observation_results'

module Observed

  class InputPlugin
    include Pluggable
    include Configurable

    attribute :tag
    attribute :system

    def observe
      raise NotImplementedError.new
    end

    def now
      Time.now
    end

  end
end
