# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'theft/version'

Gem::Specification.new do |spec|
  spec.name          = "theft"
  spec.version       = Theft::VERSION
  spec.authors       = ["Scott Vokes", "Shawn Anderson"]
  spec.email         = ["vokes.s@gmail.com", "shawn42@gmail.com"]
  spec.summary       = %q{Property-based testing for Ruby}
  spec.description   = %q{Ruby port of the theft C library.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
