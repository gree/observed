module Observed
  class Reader
    include Observed::Configurable

    def read
      fail 'Not Implemented'
    end

  end
end
