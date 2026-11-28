# Page objects for the "Set range" menu, built on the active_admin_page_objects
# gem (2.x, which needs ActiveAdmin 4). Test code only: load it from a spec
# helper with
#   require "active_admin_date_range_preset/page_objects"
# The plugin itself never requires this file, and the gemspec does not depend
# on active_admin_page_objects.
begin
  require "active_admin_page_objects"
rescue LoadError => e
  raise unless e.path == "active_admin_page_objects"

  raise LoadError, "active_admin_date_range_preset/page_objects needs the active_admin_page_objects gem (2.x) in your test group; see the active_admin_date_range_preset README"
end

ActiveAdminPageObjects.check_version!(">= 2.0.0.a", "< 3.0.0.a", plugin: "active_admin_date_range_preset")

ActiveAdminPageObjects.register_selectors(
  date_range_preset_toggle: "[data-date-range-preset-toggle]",
  date_range_preset_menu: "[data-date-range-preset-menu]",
  date_range_preset_item: "[data-date-range-preset-menu] [data-date-range-preset]"
)

require "active_admin_date_range_preset/page_objects/presets"
