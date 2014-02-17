# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'observed/http/version'

Gem::Specification.new do |spec|
  spec.name          = "observed-http"
  spec.version       = Observed::Http::VERSION
  spec.authors       = ["KUOKA Yusuke"]
  spec.email         = ["yusuke.kuoka@gree.net"]
  spec.description   = %q{observed-http}
  spec.summary       = %q{observed-http is a plugin for Observed to run health-check against Web services talking HTTP.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "observed", "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
end
