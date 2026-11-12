require "activeadmin"
require "active_admin_date_range_preset/version"

module ActiveAdminDateRangePreset
  JAVASCRIPT_MODULE = "active_admin_date_range_preset".freeze

  def self.aa_v4?
    Gem::Version.new(ActiveAdmin::VERSION) >= Gem::Version.new("4.0.0.beta1")
  end

  module Rails
    class Engine < ::Rails::Engine
      # Active Admin 4 renders its own import map, so the module is pinned
      # there. Propshaft serves it from vendor/assets/javascripts, which every
      # engine adds to the asset paths.
      initializer "active_admin_date_range_preset.importmap", after: "active_admin.importmap" do |app|
        next unless ActiveAdminDateRangePreset.aa_v4? && app.config.respond_to?(:importmap)

        ActiveAdmin.importmap.draw(root.join("config", "importmap.rb"))
      end

      # javascript_modules is pending upstream (activeadmin/activeadmin#9148).
      config.after_initialize do
        if ActiveAdmin.application.respond_to?(:javascript_modules)
          ActiveAdmin.application.javascript_modules |= [JAVASCRIPT_MODULE]
        end
      end
    end
  end
end
