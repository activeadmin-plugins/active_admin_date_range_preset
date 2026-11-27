module ActiveAdminDateRangePreset
  module PageObjects
    # What the plugin adds to a date range filter: the "Set range" menu.
    # Included in ActiveAdminPageObjects::DateRangeFilter, so every filter
    # class built on it has it, such as active_admin_datetimepicker's.
    #
    #   filter = index.filters.filter(:created_at)
    #   filter.choose_preset("Last 7 days") # => ["2026-09-24", "2026-10-01"]
    #   filter.range # => the same
    #
    # Needs a JavaScript driver.
    module Presets
      # Opens the menu, picks the preset titled +title+ and returns #range.
      # The title is the whole text of the item, ignoring case, so it is a
      # built-in one ("Today", "This Week") or one given to `add_range`.
      # @raise [Capybara::ElementNotFound] when the menu has no such preset
      # @return [Array]
      def choose_preset(title)
        find(:active_admin, :date_range_preset_toggle).click
        # The menu is appended to <body>, outside the filter.
        session = root_element.session
        begin
          session.find(:active_admin, :date_range_preset_item, text: text_pattern(title, exact: true)).click
        rescue Capybara::ElementNotFound
          offered = session.all(:active_admin, :date_range_preset_item, wait: false).map(&:text)
          raise Capybara::ElementNotFound, "no preset #{title.inspect}; the menu offers #{offered.inspect}"
        end
        range
      end

      # What the two inputs hold, as text: ["2026-09-30", "2026-10-01"].
      # @return [Array<String>]
      def range
        [from_input.value.to_s, to_input.value.to_s]
      end
    end

    ActiveAdminPageObjects::DateRangeFilter.include(Presets)
  end
end
