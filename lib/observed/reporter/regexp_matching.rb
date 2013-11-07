module Observed
  class Reporter
    module RegexpMatching

      def match(tag)
        tag_pattern.match(tag)
      end

    end
  end
end
