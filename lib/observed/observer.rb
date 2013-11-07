require 'observed/pluggable'
require 'observed/configurable'

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
