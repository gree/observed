module Observed
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
