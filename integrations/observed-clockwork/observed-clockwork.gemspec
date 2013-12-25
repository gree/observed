# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'observed/clockwork/version'

Gem::Specification.new do |spec|
  spec.name          = "observed-clockwork"
  spec.version       = Observed::Clockwork::VERSION
  spec.authors       = ["KUOKA Yusuke"]
  spec.email         = ["yusuke.kuoka@gree.net"]
  spec.description   = %q{Observed Clockwork Integration}
  spec.summary       = %q{An integration of Observed with Clockwork}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'clockwork'
  spec.add_dependency 'daemons'
  spec.add_dependency 'observed', "~> 0.2.0.rc1"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
end
