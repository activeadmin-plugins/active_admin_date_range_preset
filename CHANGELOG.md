# Changelog

## Unreleased

### Breaking

- The plugin is plain JavaScript; jQuery is no longer used. `$.fn.date_range_ext_preset`
  is removed. Use `ActiveAdminDateRangePreset.init(selector, options)` and
  `ActiveAdminDateRangePreset.defaults`. Options keep their names, so
  `$('.my_pairs').date_range_ext_preset({ show_time: true })` becomes:

  ```javascript
  document.addEventListener('DOMContentLoaded', function () {
    ActiveAdminDateRangePreset.init('.my_pairs', { show_time: true });
  });
  ```

  and `$.fn.date_range_ext_preset.defaults.show_time = true` becomes
  `ActiveAdminDateRangePreset.defaults.show_time = true`.
- `gteq_input` and `lteq_input` take CSS selectors or elements, not jQuery selectors.
- The stylesheet is plain CSS. `@import "active_admin_date_range_preset";` still works.

### Added

- Active Admin 4 support: the module is pinned into `ActiveAdmin.importmap`.
- `date` inputs get `YYYY-MM-DD` and `datetime-local` inputs get `YYYY-MM-DDTHH:MM`.
- Dark mode for the menu under the `.dark` class.
- `data-date-range-preset-toggle`, `data-date-range-preset-menu` and
  `data-date-range-preset="<key>"` hooks.
- A `.datetime_preset_pair` wrapper that holds both inputs, such as a range filter,
  fills its own first and last input.
