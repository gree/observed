module Observed
  class Config
    # @option args [Array] inputs
    # @option args [Array] outputs
    def initialize(args)
      @observers = args[:observers] || args['observers'] || fail("Missing observers in #{args}")
      @reporters = args[:reporters] || args['reporters'] || fail("Missing reporters in #{args}")
    end

    def observers
      @observers
    end

    def reporters
      @reporters
    end

    class << self

      def create(args)
        self.new(args)
      end

    end

  end
end
