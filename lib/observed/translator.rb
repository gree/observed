require 'observed/configurable'
require 'observed/logging'
require 'observed/pluggable'

module Observed
  class Translator

    include Observed::Configurable
    include Observed::Logging
    include Observed::Pluggable

    attribute :tag_pattern

    def match(tag)
      tag_pattern.match(tag)
    end

    def translate(tag, time, data)
      fail RuntimeError, 'Not implemented method: Observed#translate'
    end
  end
end
