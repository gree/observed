require 'observed/configurable'
require 'observed/pluggable'

module Observed

  class Observer
    include Pluggable
    include Configurable

    attribute :tag
    attribute :system

    def observe
      raise NotImplementedError.new
    end

  end
end
