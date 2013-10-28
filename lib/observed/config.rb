module Observed
  class Config
    # @option args [Array] inputs
    # @option args [Array] outputs
    def initialize(args)
      @inputs = args[:inputs] || args['inputs'] || fail('Missing inputs')
      @outputs = args[:outputs] || args['inputs'] || fail('Missing outputs')
    end

    def inputs
      @inputs
    end

    def outputs
      @outputs
    end

    class << self

      def create(args)
        self.new(args)
      end

    end

  end
end
