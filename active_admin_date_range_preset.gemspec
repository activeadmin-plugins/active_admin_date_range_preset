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

  # Whitelist, not a reject list: a new directory in the repo does not
  # reach consumers until it is named here. The reject form needs a new
  # pattern every time the repo grows one, and that is how 91 KB of README images under screen/
  # ended up published in the first place.
  # `vendor/` is the shipped JS.
  spec.files         = `git ls-files -z -- lib app vendor config exe bin README.md LICENSE.txt`.split("\x0")
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # lib/ requires "activeadmin" at load time, so this is a hard runtime
  # dependency, not an assumed-present host. The floor is what CI covers;
  # the ceiling is real rather than cautious: Active Admin 4 drops the
  # jquery-rails dependency and the app/assets/javascripts tree this gem
  # plugs into, so none of it loads there.
  spec.add_dependency "activeadmin", "~> 3.2"

  # Active Admin 3.2 itself still allows railties >= 6.1 and Ruby >= 2.6,
  # both of which reached end of life years ago. Declare what CI covers, so
  # the gem does not inherit that claim by silence. Every Rails 7.x series is
  # out of support: 7.1 since October 2025, 7.2 since August 2026.
  spec.add_dependency "railties", ">= 8.0"
  spec.required_ruby_version = ">= 3.3"

  spec.add_development_dependency "rake"
end
