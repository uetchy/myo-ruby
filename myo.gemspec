# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'myo/version'

Gem::Specification.new do |spec|
  spec.name          = "myo-ruby"
  spec.version       = Myo::VERSION
  spec.authors       = ["Yasuaki Uechi"]
  spec.email         = ["uetchy@randompaper.co"]
  spec.summary       = %q{Connect Myo armband in Ruby with ease}
  spec.description   = %q{Connect Myo armband in Ruby with ease}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency "em-websocket-client", "~> 0.1.2"
end