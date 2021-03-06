# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'polipus-elasticsearch'
  spec.version       = '0.0.4'
  spec.authors       = ['Stefano Fontanelli']
  spec.email         = ['s.fontanelli@gmail.com']
  spec.summary       = 'Add support for ElasticSearch in Polipus crawler'
  spec.description   = 'Add support for ElasticSearch in Polipus crawler'
  spec.homepage      = 'https://github.com/stefanofontanelli/polipus-elasticsearch'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'elasticsearch', '~> 1.0.4'
  spec.add_runtime_dependency 'elasticsearch-model', '~> 0.1.4'
  spec.add_runtime_dependency 'polipus', '~> 0.3', '>= 0.3.0'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'flexmock', '~> 1.3'
  spec.add_development_dependency 'vcr', '~> 2.9.0'
  spec.add_development_dependency 'webmock', '~> 1.20.0'
  spec.add_development_dependency 'coveralls'
end
