# coding: utf-8

Gem::Specification.new do |spec|
  spec.name = "observed-gmail"
  spec.version = "0.1.0"
  spec.authors = ["Hiroyasu OHYAMA"]
  spec.email = ["user.localhost2000@gmail.com"]
  spec.description = %q{observed-gmail}
  spec.summary = %q{This is an Observed-plugin for getting/sending email in Gmail.}
  spec.license = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "observed", "~> 0.2.0.rc1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "gmail"
  spec.add_development_dependency "simplecov"
end
