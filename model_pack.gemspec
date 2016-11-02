# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'model_pack/version'

Gem::Specification.new do |spec|
  spec.name          = 'model_pack'
  spec.version       = ModelPack::VERSION
  spec.authors       = ['Maksim V.']
  spec.email         = ['inre.strom@gmail.com']
  spec.summary       = 'Using Ruby classes aka ("models") with smart serialization mechanizm'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/emmygems'
  spec.license       = 'MIT'

  spec.required_ruby_version     = '>= 2.1.0'
  spec.required_rubygems_version = '>= 2.3.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
