# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prawn_calendar/version'

Gem::Specification.new do |spec|
  spec.name          = "prawn_calendar"
  spec.version       = PrawnCalendar::VERSION
  spec.authors       = ["Bernhard Weichel"]
  spec.email         = ["github.com@nospam.weichel21.de"]
  spec.description   = %q{This gem provides a function to generate calendars and calendar entries.}
  spec.summary       = %q{generate calendars with prawn}
  spec.homepage      = "https://github.com/bwl21/prawn_calendar"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "prawn" "~> 1.0.0.rc2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
