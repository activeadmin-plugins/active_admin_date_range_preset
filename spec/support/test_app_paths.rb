require 'rails/version'

# Where the generated dummy app lives, and under what name.
#
# The name has to carry every input that changes what gets generated.
# Keying on the Rails version alone meant `AA=3.2.0 rspec` silently reused an
# app whose active_admin:install had been run by a different Active Admin, so
# the leg reported on a build it never produced.
module TestAppPaths
  module_function

  def app_dir_name
    "rails-#{Rails::VERSION::STRING}-aa#{ENV['AA'] || 'default'}"
  end

  def app_root
    File.expand_path("../rails/#{app_dir_name}", __dir__)
  end
end
