# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_admin_date_range_preset/version'

Gem::Specification.new do |spec|
  spec.name          = "active_admin_date_range_preset"
  spec.version       = ActiveAdminDateRangePreset::VERSION
  spec.authors       = ["Gena M."]
  spec.email         = ["workgena@gmail.com"]

  spec.summary       = %q{date_range_preset extension for ActiveAdmin}
  spec.description   = %q{Integrate useful fast links to set date ranges in to ActiveAdmin, for example today range, week range, month range}
  spec.homepage      = "https://github.com/workgena/active_admin_date_range_preset"
  spec.license       = "MIT"

  # `screen/` is README images — 91 KB, 98% of the published gem, for
  # pictures that render from GitHub and are never read from the
  # package. `.idea/` is a JetBrains project file. `vendor/` stays:
  # that is the shipped JS.
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|screen|\.idea)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
