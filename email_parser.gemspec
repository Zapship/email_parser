# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'email_parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'email_parser'
  spec.version       = EmailParser::VERSION
  spec.authors       = ['Sebastian Kreft']
  spec.email         = ['skreft@zapship.com']
  spec.license       = 'All rights reserved, Zapship 2015'
  spec.summary       = 'Parse emails'
  spec.description   = 'Parse emails'
  spec.homepage      = 'https://github.com/Zapship/email_parser'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir['{data,lib}/**/*', 'Rakefile', 'README.md']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']


  spec.executables << 'parse_mbox'

  spec.required_ruby_version = '~> 2.2'

  spec.add_runtime_dependency 'mail', '~> 2.7.1'
  spec.add_runtime_dependency 'nokogiri', '>= 1.8.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
