require_relative '../spec/support/test_app_paths'

desc 'Creates a test rails app for the specs to run against'
task :setup do

  rails_new_args = %w[
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    -m
    spec/support/rails_template.rb
  ].join(' ')

  puts "[setup] Rails #{Rails::VERSION::STRING} / Active Admin #{ENV['AA'] || '(Gemfile default)'}"

  abort 'rails new failed' unless
    system("bundle exec rails new spec/rails/#{TestAppPaths.app_dir_name} #{rails_new_args}")
end
