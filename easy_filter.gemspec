# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_filter/version'

Gem::Specification.new do |spec|
  spec.name          = 'easy_filter'
  spec.version       = EasyFilter::VERSION
  spec.authors       = ['Peter Kepes']
  spec.email         = ['kepes.peter@codeplay.hu']
  spec.description   = 'Filter and sort ActiveRecord model for Rails app with Bootstrap view helpers'
  spec.summary       = 'ActiveRecord model filter'
  spec.homepage      = 'https://github.com/kepes/easy-filter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'activerecord', '~> 3.2'
  spec.add_development_dependency 'sqlite3'
  spec.add_runtime_dependency 'jquery-rails', '~> 3.1.4'
  spec.add_runtime_dependency 'jquery-ui-rails', , '~> 5.0.5'
end
