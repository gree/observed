module Observed
  # Indicates that classes included this module to have attributes which are configurable.
  # `configurable` means that the attributes can be configured via named parameters of
  # the constructor and the `configure` instance method of the class included this module.
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
      self
    end

    # @param [String|Symbol] name
    def has_attribute_value?(name)
      !! get_attribute_value(name)
    end

    # @param [String|Symbol] name
    # @return [Object] In order of precedence, the value of the instance variable named `"@" + name`,
    #                  or the value `@attributes[name]`, or the default value for the attribute named `name`
    def get_attribute_value(name)
      instance_variable_get("@#{name.to_s}") || @attributes[name] || self.class.defaults[name]
    end

    module ClassMethods
      # @param [String|Symbol] name
      def attribute(name, options={})
        define_method(name) do
          get_attribute_value(name) || fail_for_not_configured_parameter(name)
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

      # Inherits the default values stored in @defaults to the sub-class
      def inherited(klass)
        super if defined? super
        klass.default defaults
      end

    end

    module ModuleMethods
      # @param [String|Symbol] name
      def attribute(name, options={})
        @attributes ||= {}
        @attributes = @attributes.merge(name => options)
      end

      def attributes
        @attributes ||
          fail(<<EOS
#{self} includes Observed::Configurable. Though, no attributes are configured for #{self}.
We don't need to include Observed::Configurable, or it might be a bug?
EOS
              )
      end

      def included(klass)
        ensure_configurable klass

        attributes.each do |name, options|
          klass.attribute name, options
        end
      end

      def ensure_configurable(klass)
        unless klass.include? Configurable
          fail "The class #{klass} must include Observed::Configurable to include #{self}"
        end
      end
    end

    class NotConfiguredError < RuntimeError; end

    class << self
      def included(klass)
        if klass.is_a? Class
          klass.extend ClassMethods
        else
          klass.extend ModuleMethods
        end
      end
    end

    private

    def fail_for_not_configured_parameter(name)
      fail NotConfiguredError.new("The parameter `#{name}` is not configured. attributes=#{@attributes}, defaults=#{self.class.defaults}")
    end

  end
end
