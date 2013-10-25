module Observed
  module Pluggable

    module ClassMethods
      def plugins
        @plugins ||= []
      end

      def inherited(klass)
        plugins << klass
      end
    end

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

  end
end
