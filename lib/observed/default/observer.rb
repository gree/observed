require 'observed/observer'

module Observed
  module Default
    class Observer < Observed::Observer

      def observe(data)
        [tag, data]
      end

    end
  end
end
