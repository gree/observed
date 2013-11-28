require 'observed/version'
require 'observed/context'
require 'observed/builtin_plugins'
require 'forwardable'

# The module to provide DSL to describe Observed configuration, intended to be used by including to Ruby's `main` object
# like Clockwork(https://github.com/tomykaira/clockwork) does in their configuration file(a.k.a `clockwork.rb`).
#
# Take this as the `Builder` for Observed's configuration which is has global state.
# As it has global state, we have to call `Observed#init!` before building multiple Observed configurations through
# this module.
#
# @example
# require 'observed'
# include Observed
#
# require 'observed/http'
# require_relative 'your_plugin'
#
# observe 'myservice.response', { plugin: 'http', method: 'get', url: 'http://localhost:3000' }
# report /myservice.response/, { plugin: 'stdout' }
#
# #=> Now we can obtain the described configuration by calling `Observed.config`
module Observed

  class Singleton
    extend Forwardable

    def_delegators :@observed, :require_relative, :observe, :translate, :report, :write, :read, :config, :load!, :working_directory

    # Call this method before you are going to build 2nd or later Observed configuration using this module.
    # Refrain that `Observed` object is a builder for Observed configuration and it has global state.
    # We have to reset its state via this `init!` method before building next configurations after the first one.
    def init!
      @context = Observed::Context.new
      @observed = @context.config_dsl
    end

    def run(tag=nil)
      sys = @context.system
      sys.config = @observed.config
      sys.run(tag)
    end

    def configure(*args)
      @context.configure *args
    end
  end

  class << self
    def included(klass)
      ensure_singleton_initialized
    end

    def extended(klass)
      ensure_singleton_initialized
    end

    def ensure_singleton_initialized
      @@singleton ||= begin
        s = Singleton.new
        s.init!
        s
      end
    end
  end

  extend Forwardable

  def_delegators :@@singleton, :run, :init!, :configure, :require_relative, :observe, :translate, :report, :write, :read, :config,
                 :load!, :working_directory

  extend self

end
