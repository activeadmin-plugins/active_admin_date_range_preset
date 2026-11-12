require 'fileutils'

# Active Admin 4 serves a Tailwind build of the host's active_admin.css. Build
# it with the gem's CSS imported, the way the README tells hosts to, so the
# layout specs measure what a host would see. Rebuilt every run because the
# dummy app is cached and the gem's CSS may have changed since.
module TailwindBuild
  module_function

  def compile!
    return unless ActiveAdminDateRangePreset.aa_v4?

    aa_path = Gem.loaded_specs['activeadmin'].full_gem_path
    gem_css = File.expand_path('../../vendor/assets/stylesheets/active_admin_date_range_preset.css', __dir__)
    app_root = ENV['RAILS_ROOT']
    input = File.join(app_root, 'tmp/active_admin_tailwind_input.css')
    output = File.join(app_root, 'app/assets/stylesheets/active_admin.css')

    FileUtils.mkdir_p(File.dirname(input))
    File.write(input, <<~CSS)
      @import "tailwindcss";
      @import "#{gem_css}";
      @plugin "#{aa_path}/plugin.js";
      @custom-variant dark (&:where(.dark, .dark *));
      @source "#{aa_path}/app/views/**/*";
      @source "#{aa_path}/lib/active_admin/**/*";
      @source "#{aa_path}/vendor/javascript/flowbite.js";
      @source "#{aa_path}/plugin.js";
      @source "#{app_root}/app/admin/**/*";
      @source "#{app_root}/app/views/**/*";
    CSS

    cli = Gem.bin_path('tailwindcss-ruby', 'tailwindcss')
    system(cli, '-i', input, '-o', output, out: File::NULL, err: File::NULL) or
      raise 'tailwindcss build failed'
  end
end

RSpec.configure do |config|
  config.before(:suite) { TailwindBuild.compile! }
end
