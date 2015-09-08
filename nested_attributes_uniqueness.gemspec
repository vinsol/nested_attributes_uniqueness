# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nested_attributes_uniqueness/version'

Gem::Specification.new do |spec|
  spec.name          = "nested_attributes_uniqueness"
  spec.version       = NestedAttributesUniqueness::VERSION
  spec.authors       = ["Akshay", "Ankit", "Udit"]
  spec.email         = ["akshay.vishnoi@vinsol.com", "ankit.bansal@vinsol.com", "udit@vinsol.com"]

  spec.summary       = %q{Checks for uniqueness vaidation in nested attributes for objects in memory .}
  spec.description   = %q{Checks for uniqueness vaidation in nested attributes for objects in memory .}
  spec.homepage      = "https://github.com/vinsol/nested_attributes_uniqueness"
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://mygemserver.com'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "coveralls", "~> 0.8.2"
  spec.add_development_dependency "activerecord", ">=3.2.0"
  spec.add_development_dependency "activesupport", ">=3.2.0"
  spec.add_development_dependency "sqlite3"
end
