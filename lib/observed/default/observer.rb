require 'observed/observer'

module Observed
  module Default
    class Observer < Observed::Observer

      attribute :reader

      def observe
        data = reader.read
        system.report(tag, data)
      end

    end
  end
end
