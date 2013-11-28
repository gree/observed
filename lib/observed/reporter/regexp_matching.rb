module Observed
  class Reporter
    module RegexpMatching

      def match(tag)
        tag_pattern = get_attribute_value(:tag_pattern)
        tag_pattern.match(tag) if tag_pattern
      end

    end
  end
end
