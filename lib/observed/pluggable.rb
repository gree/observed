module Observed
  # Indicates that the class is pluggable (or extensible or a extension point).
  # "pluggable" means that the class included this module will be the outlet in where Observed plug-ins are plugged.
  #
  # @example
  # class Reader
  #   include Pluggable
  # end
  # class FooReader < Reader; end
  # class BarReader < Reader; end
  # Reader.plugins #=> [FooReader, BarReader]
  module Pluggable

    module ClassMethods
      def plugins
        @plugins ||= []
      end

      def inherited(klass)
        super if defined? super
        plugins << klass
      end

      def plugin_name(plugin_name=nil)
        @plugin_name = plugin_name if plugin_name
        @plugin_name
      end

      def find_plugin_named(plugin_name)
        plugins.find { |plugin| plugin.plugin_name == plugin_name }
      end

      def select_named_plugins
        plugins.select(&:plugin_name)
      end
    end

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

  end
end
