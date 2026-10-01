source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_date_range_preset.gemspec
gemspec

default_rails_version = '7.1.0'
default_activeadmin_version = '3.5.0'

gem 'rails', "~> #{ENV['RAILS'] || default_rails_version}"
gem 'activeadmin', "~> #{ENV['AA'] || default_activeadmin_version}"
gem 'sprockets-rails'
gem 'sass-rails'

group :test do
  gem 'simplecov', require: false
  gem 'rspec-rails'
  gem 'sqlite3', '~> 2.0'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'cuprite'
  gem 'webrick', require: false
end
