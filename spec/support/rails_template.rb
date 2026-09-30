# Rails template to build the sample app for specs

# Ensure Sprockets manifest exists (Rails 8.0+ no longer generates it)
FileUtils.mkdir_p("app/assets/config")
File.write("app/assets/config/manifest.js", "//= link_tree ../images\n")

# The generated test env eager loads only when CI is set, and without eager
# loading Zeitwerk drops Active Admin's own constants (ActiveAdmin::BatchActions
# and friends) during boot. Pin it so a local run matches CI.
gsub_file "config/environments/test.rb", /config\.eager_load\s*=.*/, "config.eager_load = true"

generate :model, 'post title:string body:text published_at:datetime --force'

inject_into_file "app/models/post.rb",
  "  def self.ransackable_attributes(auth_object = nil)\n" \
  "    [\"title\", \"body\", \"published_at\", \"created_at\"]\n" \
  "  end\n",
  after: "ApplicationRecord\n"

# Add our local gem to the load path (Rails 7.1+)
gsub_file "config/environment.rb",
  'require_relative "application"',
  "require_relative \"application\"\n$LOAD_PATH.unshift('#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))}')\nrequire \"active_admin\"\n"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'

# Install active_admin_date_range_preset assets
inject_into_file "app/assets/stylesheets/active_admin.scss",
                 "@import \"active_admin_date_range_preset\";\n",
                 after: "@import \"active_admin/base\";\n"

inject_into_file "app/assets/javascripts/active_admin.js",
                 "//= require active_admin_date_range_preset\n",
                 after: "//= require active_admin/base\n"

# Documented wiring for date_range filters (README "Using with ActiveAdminDatetimepicker")
append_to_file "app/assets/javascripts/active_admin.js", <<~JS
  $(function () {
    $('form.filter_form div.filter_date_range').date_range_ext_preset();
  });
JS

# The dummy app's own test/ and generator-made spec/ would otherwise be
# picked up by `rspec spec` from the gem root.
run "rm -rf test spec"
route "root :to => 'admin/dashboard#index'"
rake "db:migrate"

# Remove Gemfile last so rake/route/generate work during template
run "rm -f Gemfile Gemfile.lock"
