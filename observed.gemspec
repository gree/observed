# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'observed/version'

Gem::Specification.new do |spec|
  spec.name          = "observed"
  spec.version       = Observed::VERSION
  spec.authors       = ["KUOKA Yusuke"]
  spec.email         = ["yusuke.kuoka@gree.net"]
  spec.description   = %q{Observed}
  spec.summary       = %q{Observed is a health-check framework for various services}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "simplecov"
end
