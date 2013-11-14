require 'observed/configurable'

module Observed
  # The configuration for Observed which may be built by Observed::Builder,
  # which may contains configured writers, readers, reporters, observers.
  class Config

    include Observed::Configurable

    # !@attribute [rw] writers
    #  @return [Array<Observed::Writer>]
    attribute :writers

    # !@attribute [rw] readers
    #  @return [Array<Observed::Reader>]
    attribute :readers

    # !@attribute [rw] reporters
    #  @return [Array<Observed::Reporter>]
    attribute :reporters

    # !@attribute [rw] observers
    #  @return [Array<Observed::Observer>]
    attribute :observers

    # !@attribuet [rw] translators
    #  @return [Array<Observed::Translator]
    attribute :translators

  end
end
