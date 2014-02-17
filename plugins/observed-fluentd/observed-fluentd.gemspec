# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'observed/fluentd/version'

Gem::Specification.new do |spec|
  spec.name          = 'observed-fluentd'
  spec.version       = Observed::Fluentd::VERSION
  spec.authors       = ['KUOKA Yusuke']
  spec.email         = %w(yusuke.kuoka@gree.net)
  spec.description   = %q{Observed Fluentd Output Plugin}
  spec.summary       = %q{observed-fluentd is an Observed output plugin for sending observed data to Fluentd}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency "observed", "~> 0.2"
  spec.add_dependency 'fluent-logger', '~> 0.4.6'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
