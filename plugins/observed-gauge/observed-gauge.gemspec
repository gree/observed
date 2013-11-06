# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'observed/gauge/version'

Gem::Specification.new do |spec|
  spec.name          = 'observed-gauge'
  spec.version       = Observed::Gauge::VERSION
  spec.authors       = ['KUOKA Yusuke']
  spec.email         = ['yusuke.kuoka@gree.net']
  spec.description   = %q{Gauge plugin for Observed}
  spec.summary       = %q{A plugin to consolidate outputs from other Observed output plugins by averaging values by averaging them over configured periods}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'observed', '~> 0.0.1'
  spec.add_dependency 'rrd-ffi', '~> 0.2.14'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'simplecov'
end
