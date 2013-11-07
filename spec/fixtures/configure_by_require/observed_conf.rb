require 'observed'
include Observed

require_relative '../configure_by_conf/foo_plugin'

observe 'foo', { plugin: 'foo' }
