require 'observed/configurable'
require 'observed/pluggable'

module Observed
  class Writer
    include Observed::Configurable
    include Observed::Pluggable

    def write(tag, time, data)
      fail 'Not Implemented'
    end

  end
end
