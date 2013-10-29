require 'observed/pluggable'
require 'observed/configurable'

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
