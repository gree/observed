require 'observed/pluggable'
require 'observed/configurable'

module Observed
  class Reporter
    include Pluggable
    include Configurable

    # !@attribute [r] tag_pattern
    #   @return [Regexp]
    attribute :tag_pattern

    attribute :system

    # @param [String] tag
    def match(tag)
      raise NotImplementedError.new
    end

    def report(tag, time, data)
      raise NotImplementedError.new
    end

  end
end
