# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rusql/version'

Gem::Specification.new do |spec|
  spec.name          = "rusql"
  spec.version       = Rusql::VERSION
  spec.authors       = ["Ajith Hussain"]
  spec.email         = ["csy0013@googlemail.com"]

  spec.summary       = %q{rusql provides a DSL for building SQL queries}
  spec.homepage      = "http://github.com/sparkymat/rusql"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
