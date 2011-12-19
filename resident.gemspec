lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'national_identification_number'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 1.8.7"
  s.require_paths << 'lib'

  s.name        = 'resident'
  s.version     = '0.0.9'
  s.summary     = 'Validate National Identification Numbers.'
  s.homepage    = "http://github.com/bukowskis/national_identification_number/"
  s.author      = 'Bukowskis'
  s.license     = "MIT-LICENSE"

  s.has_rdoc = true
  s.rdoc_options     = %w{ --main README.rdoc --charset=UTF-8}
  s.extra_rdoc_files = %w{ README.rdoc MIT-LICENSE }

  s.test_files = %w{
    spec/national_identification_number/base_spec.rb
    spec/national_identification_number/finnish_spec.rb
    spec/national_identification_number/swedish_spec.rb
  }
  s.files      = Dir.glob("lib/**/*") + %w{ MIT-LICENSE README.rdoc .gemtest }

  s.add_development_dependency "rspec"
end