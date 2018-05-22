
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fcrepo/cloud/migrator/version'

Gem::Specification.new do |spec|
  spec.name          = 'fcrepo-cloud-migrator'
  spec.version       = Fcrepo::Cloud::Migrator::VERSION
  spec.authors       = ['Carrick Rogers', 'Brendan Quinn']
  spec.email         = ['carrickr@umich.edu', 'brendan-quinn@northwestern.edu']

  spec.summary       = 'This gem is for migrating local fcrepo to AWS fcrepo'
  spec.description   = 'Pushes the binaries to s3 and modifies appropriate ' \
                       'ttl files accordingly'
  spec.homepage      = 'https://github.com/nulib/fcrepo-cloud-migrator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'rdf-turtle'

  spec.add_development_dependency 'bixby'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
