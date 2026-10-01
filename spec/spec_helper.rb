require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH << File.expand_path('../support', __FILE__)

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
require 'bundler'
Bundler.setup

ENV['RAILS_ENV'] = 'test'
require 'rails'
require 'fileutils'
require_relative 'support/test_app_paths'
ENV['RAILS_ROOT'] = TestAppPaths.app_root

# Create the test app if it doesn't exist. rails new creates the target
# directory before the template runs, so a template that fails halfway leaves
# the directory behind and every later run would skip regeneration and die on
# config/environment.rb instead of reporting the real error. Check the file the
# suite actually loads, and refuse to continue if the build did not succeed.
unless File.exist?(File.join(ENV['RAILS_ROOT'], 'config', 'environment.rb'))
  FileUtils.rm_rf(ENV['RAILS_ROOT'])
  abort 'rake setup failed; dummy app not built' unless system('rake setup')
end

require 'active_model'
# require ActiveRecord to ensure that Ransack loads correctly
require 'active_record'
require 'action_view'
require 'active_admin'
ActiveAdmin.application.load_paths = [ENV['RAILS_ROOT'] + '/app/admin']
require ENV['RAILS_ROOT'] + '/config/environment.rb'
# Disabling authentication in specs so that we don't have to worry about
# it all over the place
ActiveAdmin.application.authentication_method = false
ActiveAdmin.application.current_user_method = false

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'support/admin'
require 'support/capybara'
require 'support/browser_time'

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    ActiveRecord::Migration.maintain_test_schema!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
