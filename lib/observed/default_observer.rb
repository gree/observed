require 'observed/observer'

module Observed
  class DefaultObserver < Observer

    attribute :reader

    def observe
      data = reader.read
      system.report(tag, data)
    end

  end
end
