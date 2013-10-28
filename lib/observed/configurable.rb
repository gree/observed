module Observed
  module Configurable

    module ClassMethods
      # @param [Symbol] name
      def attribute(name)
        define_method(name) do
          instance_variable_get("@#{name.to_s}") || @attributes[name] || self.class.defaults[name] || fail_because_of_non_configured_parameter(name)
        end
      end

      def default(args)
        @defaults = defaults.merge(args)
      end

      def defaults
        @defaults ||= {}
      end

      def create(args)
        self.new(args)
      end

    end

    class NotConfiguredError < RuntimeError; end

    def initialize(args={})
      configure(args)
    end

    def configure(args={})
      if @attributes
        @attributes.merge! args
      else
        @attributes ||= args.dup
      end
    end

    def default_value_for(name)
      self.class.defaults[name]
    end

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

    private

    def fail_because_of_non_configured_parameter(name)
      fail NotConfiguredError.new("The parameter `#{name}` is not configured.")
    end

  end
end
