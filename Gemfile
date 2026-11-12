source 'https://rubygems.org'

# Specify your gem's dependencies in active_admin_date_range_preset.gemspec
gemspec

default_rails_version = '8.0.0'
default_activeadmin_version = '3.5.0'

activeadmin_version = ENV['AA'] || default_activeadmin_version

gem 'rails', "~> #{ENV['RAILS'] || default_rails_version}"
gem 'activeadmin', "~> #{activeadmin_version}"

# Active Admin 4 has no Sprockets: its layout renders an import map and a
# Tailwind-built stylesheet.
if Gem::Version.new(activeadmin_version) >= Gem::Version.new('4.0.0.beta1')
  gem 'propshaft'
  gem 'importmap-rails'
  gem 'tailwindcss-ruby', '~> 4.0'
else
  gem 'sprockets-rails'
  gem 'sass-rails'
end

group :test do
  gem 'simplecov', require: false
  gem 'rspec-rails'
  gem 'sqlite3', '~> 2.0'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'cuprite'
  gem 'webrick', require: false
end
