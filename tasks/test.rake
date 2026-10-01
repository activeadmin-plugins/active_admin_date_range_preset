desc 'Creates a test rails app for the specs to run against'
task :setup do
  require 'rails/version'

  # Rails 8.1 wires importmap-rails into the generated ApplicationController
  # (stale_when_importmap_changes). This app runs on Sprockets, so that gem is
  # absent and the controller raises NameError at boot, before any example.
  # Skipping JavaScript stops the macro being generated; the Active Admin
  # bundle the specs exercise comes from active_admin:install, not from
  # rails new, so nothing the suite needs goes with it.
  rails_new_args = %w[
    --skip-javascript
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    -m
    spec/support/rails_template.rb
  ].join(' ')

  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING} #{rails_new_args}"
end
