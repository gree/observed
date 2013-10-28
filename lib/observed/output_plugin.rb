require 'observed/pluggable'
require 'observed/configurable'
require 'observed/plugin/observation_result'
require 'observed/plugin/observation_results'

module Observed

  class OutputPlugin
    include Pluggable
    include Configurable

    # !@attribute [r] tag_pattern
    #   @return [Regexp]
    attribute :tag_pattern

    attribute :system

    # @param [String] tag
    def match(tag)
      tag.match(tag_pattern)
    end

    def emit(tag, time, data)
      raise NotImplementedError.new
    end

    def now
      Time.now
    end

  end
end
