module Observed
  module Configurable

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

    module ClassMethods
      # @param [Symbol] name
      def attribute(name, options={})
        define_method(name) do
          instance_variable_get("@#{name.to_s}") || @attributes[name] || self.class.defaults[name] || fail_because_of_non_configured_parameter(name)
        end
        default_value =  options && options[:default]
        default name => default_value if default_value
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

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

    private

    def default_value_for(name)
      self.class.defaults[name]
    end

    def fail_because_of_non_configured_parameter(name)
      fail NotConfiguredError.new("The parameter `#{name}` is not configured.")
    end

  end
end
