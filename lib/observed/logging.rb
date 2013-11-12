require 'observed/configurable'

module Observed
  module Logging
    include Observed::Configurable

    # !@attribute [r] logger
    #  @return [Logger]
    attribute :logger
  end
end
