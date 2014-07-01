# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stagger/version'

Gem::Specification.new do |spec|
  spec.name          = "stagger"
  spec.version       = Stagger::VERSION
  spec.authors       = ["Valentin Vasilyev"]
  spec.email         = ["valentin.vasilyev@outlook.com"]
  spec.summary       = %q{Gem evenly distributes items across business days}
  spec.homepage      = "https://github.com/valve/stagger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "activesupport"
end
