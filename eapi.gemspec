# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eapi/version'

Gem::Specification.new do |spec|
  spec.name          = "eapi"
  spec.version       = Eapi::VERSION
  spec.authors       = ["Eduardo Turiño"]
  spec.email         = ["eturino@eturino.com"]
  spec.summary       = %q{ruby gem for building complex structures that will end up in hashes (initially devised for ElasticSearch search requests)}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "pry-rescue"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "pry-doc"

  spec.add_dependency 'activesupport', '~> 4'
  spec.add_dependency 'activemodel', '~> 4'
end
