# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday/scrublogs/version'

Gem::Specification.new do |gem|
  gem.name          = "faraday-scrublogs"
  gem.version       = Faraday::ScrubLogs::VERSION
  gem.authors       = ["petems"]
  gem.email         = ["p.morsou@gmail.com"]
  gem.description   = %q{Faraday middleware to scrub logs.}
  gem.summary       = %q{Faraday middleware to scrub logs.}
  gem.homepage      = "https://github.com/petems/faraday-scrublogs"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "faraday", "~> 0.8"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "service_double"
end
