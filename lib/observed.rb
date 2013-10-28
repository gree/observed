require 'observed/version'
require 'observed/config_dsl'
require 'forwardable'

module Observed
  extend self
  extend Forwardable

  @@observed = Observed::ConfigDSL.new

  def_delegators :@@observed, :require, :observe, :config, :load!

  def init!
    @@observed = Observed::ConfigDSL.new
  end

  def configure(*args)
    @@observed.send :configure, *args
  end

end
