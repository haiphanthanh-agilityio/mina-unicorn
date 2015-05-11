# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mina/unicorn/version'

Gem::Specification.new do |spec|
  spec.name          = 'mina-unicorn'
  spec.version       = Mina::Unicorn::VERSION
  spec.authors       = ['Hai Phan']
  spec.email         = ['hai.phanthanh@asnet.com.vn']
  spec.description   = %q{Unicorn tasks for Mina}
  spec.summary       = %q{Unicorn tasks for Mina}
  spec.homepage      = 'https://github.com/haiphan-asnet/mina-unicorn'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mina'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
