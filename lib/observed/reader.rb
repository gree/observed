require 'observed/configurable'
require 'observed/pluggable'

module Observed
  class Reader
    include Observed::Configurable
    include Observed::Pluggable

    def read
      fail 'Not Implemented'
    end

  end
end
