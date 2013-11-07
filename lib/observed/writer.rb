module Observed
  class Writer
    include Observed::Configurable

    def write(tag, time, data)
      fail 'Not Implemented'
    end

  end
end
