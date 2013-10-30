require 'observed'
include Observed

configure plugins_directory: 'spec/fixtures/configure_by_conf'
observe 'foo', { plugin: 'foo' }
