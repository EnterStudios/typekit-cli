lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'typekit'

Gem::Specification.new do |gem|
  gem.name          = Typekit::NAME
  gem.version       = Typekit::VERSION
  gem.date          = Date.today.to_s

  gem.summary       = 'Command line interface for interacting with the Typekit API'
  gem.description   = gem.summary
  gem.authors       = ['Matthew Case']
  gem.files         = Dir['lib/**/*.rb']
  gem.homepage      = 'https://github.com/ascendantlogic/typekit-cli'
  gem.license       = 'MIT'

  gem.executables   = ['typekit']

  gem.require_paths = ['lib']

  gem.add_dependency 'thor', '~> 0.19.1'
  gem.add_dependency 'httparty', '~> 0.13.1'
  gem.add_dependency 'formatador', '~> 0.2.5'

  gem.add_development_dependency 'rspec', '~> 3.3.0'
  gem.add_development_dependency 'webmock', '~> 1.21.0'
end
