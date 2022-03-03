lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'national_identification_number'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 1.9.3"
  s.require_paths << 'lib'

  s.name        = 'resident'
  s.version     = '0.0.12'
  s.summary     = 'Validate National Identification Numbers.'
  s.homepage    = "http://github.com/bukowskis/national_identification_number/"
  s.author      = 'Bukowskis'
  s.license     = "MIT-LICENSE"

  s.files       = Dir['{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*', '*LICENSE'] & `git ls-files -z`.split("\0")

  s.add_development_dependency('rspec')
  s.add_development_dependency('timecop')
end
