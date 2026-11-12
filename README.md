[![Gem Version](https://badge.fury.io/rb/active_admin_date_range_preset.svg)](https://badge.fury.io/rb/active_admin_date_range_preset)
[![NPM Version](https://badge.fury.io/js/@activeadmin-plugins%2Factive_admin_date_range_preset.svg)](https://badge.fury.io/js/@activeadmin-plugins%2Factive_admin_date_range_preset)
![npm](https://img.shields.io/npm/dm/@activeadmin-plugins/active_admin_date_range_preset)
[![CI](https://github.com/activeadmin-plugins/active_admin_date_range_preset/actions/workflows/ci.yml/badge.svg)](https://github.com/activeadmin-plugins/active_admin_date_range_preset/actions/workflows/ci.yml)

# active_admin_date_range_preset

Preset links for ActiveAdmin date_range inputs in sidebar filters in forms

This is how it looks like

<img width="1008" height="942" alt="combined" src="https://github.com/user-attachments/assets/cbe22410-078e-4f2b-894b-4457c13e3e22" />



## Compatibility

Active Admin 3.2 or newer, including Active Admin 4. Rails 8.0 or newer, Ruby
3.3 or newer. CI covers Active Admin 3.2 and 3.5 on Ruby 3.3, 3.4 and 4.0
against Rails 8.0 and 8.1, and Active Admin 4.0.0.beta23 on Rails 8.0 and 8.1.

The plugin is one plain JavaScript file with no jQuery. Active Admin 3 loads it
through Sprockets, Active Admin 4 as an ES module from its import map. Both get
the same API, `window.ActiveAdminDateRangePreset`.

Version 0.4.0 raised the Rails floor from 7.1 to 8.0. Stay on 0.3.x if you are
still on Rails 7.

The Rails and Ruby floors are declared explicitly because Active Admin 3.2
still allows `railties >= 6.1` and Ruby `>= 2.6`, both long past end of life
and neither tested here.

## Upgrading from 0.x

The jQuery plugin `$.fn.date_range_ext_preset` is gone. Replace each call with
`ActiveAdminDateRangePreset.init`, which takes a CSS selector (or an element,
or a list of elements) and the same options:

```javascript
// before
$('form.filter_form div.filter_date_range').date_range_ext_preset({ show_time: true });
$.fn.date_range_ext_preset.defaults.hours_offset = 3;

// after
document.addEventListener('DOMContentLoaded', function () {
  ActiveAdminDateRangePreset.init('form.filter_form div.filter_date_range', { show_time: true });
});
ActiveAdminDateRangePreset.defaults.hours_offset = 3;
```

Every option keeps its name and meaning, `show_time` included. A call that
turned time on for some inputs becomes:

```javascript
// before
$('.my_pairs').date_range_ext_preset({ show_time: true });

// after
document.addEventListener('DOMContentLoaded', function () {
  ActiveAdminDateRangePreset.init('.my_pairs', { show_time: true });
});
```

To turn it on for every pair, including the ones set up automatically, set
the default instead, outside any `DOMContentLoaded` callback:

```javascript
ActiveAdminDateRangePreset.defaults.show_time = true;
```

`show_time` still affects text inputs only. Native `date` and `datetime-local`
inputs get the format their `type` requires.

`gteq_input` and `lteq_input` are now CSS selectors or elements instead of
jQuery selectors. The markup and CSS classes are unchanged. The stylesheet is
plain CSS now, so `@import "active_admin_date_range_preset";` in
`active_admin.scss` keeps working.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_admin_date_range_preset'
```

And then execute:

    $ bundle install

### Active Admin 3 (Sprockets)

In `app/assets/javascripts/active_admin.js`:

```javascript
//= require active_admin_date_range_preset
```

In `app/assets/stylesheets/active_admin.scss`:

```scss
@import "active_admin_date_range_preset";
```

### Active Admin 4 (import map)

The gem pins the module `active_admin_date_range_preset` into
`ActiveAdmin.importmap`. If your Active Admin has the `javascript_modules`
setting, the gem adds itself to it and pages import it automatically.
Otherwise, override `app/views/active_admin/_html_head.html.erb` (copy it from
Active Admin) and add after the `javascript_importmap_tags` line:

```erb
<%= javascript_import_module_tag "active_admin_date_range_preset" %>
```

If you use active_admin_theme 4, add the module to its list in an initializer
instead:

```ruby
ActiveAdminTheme.javascripts += %w[active_admin_date_range_preset]
```

For the CSS, either link the stylesheet in the same `_html_head` override
(Propshaft serves it from the gem):

```erb
<%= stylesheet_link_tag "active_admin_date_range_preset" %>
```

or import it into the Tailwind entry that builds `active_admin.css`, from the
npm package or from the gem's path (`bundle show active_admin_date_range_preset`):

```css
@import "@activeadmin-plugins/active_admin_date_range_preset";
```

The menu follows Active Admin 4's dark mode (the `.dark` class on `<html>`).

### npm package

    $ npm i @activeadmin-plugins/active_admin_date_range_preset

```javascript
import '@activeadmin-plugins/active_admin_date_range_preset';
```

```css
@import '@activeadmin-plugins/active_admin_date_range_preset';
```

## Usage

### Forms

Put `datetime_preset_pair` on the wrapper of the first input of a pair. The
next input is the end of the range. Pairs with this class are set up on page
load.

```ruby
f.input :date_from, as: :string, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
f.input :date_to, as: :string
```

The value format follows the input's `type`:

| Input | Value |
| --- | --- |
| `type="date"` | `2015-06-10` |
| `type="datetime-local"` | `2015-06-10T00:00` |
| text | `2015-06-10`, or `2015-06-10 00:00:00` with `show_time` |

`data-show-time` overrides `show_time` for that pair, in both directions.

### Filters

A wrapper that holds both inputs uses its first and last input. Add the class
to a date_range filter:

```ruby
filter :created_at, as: :date_range, wrapper_html: { class: 'datetime_preset_pair' }
```

Or set up every date_range filter from JavaScript:

```javascript
// Active Admin 3
ActiveAdminDateRangePreset.init('form.filter_form div.filter_date_range');
// Active Admin 4
ActiveAdminDateRangePreset.init('form.filters-form div.date_range');
```

On Active Admin 4, put that call in a module script in your `_html_head`
override, after the import:

```erb
<script type="module">
  import "active_admin_date_range_preset";
  ActiveAdminDateRangePreset.init("form.filters-form div.date_range");
</script>
```

Active Admin 4's own date_range filter renders native date inputs, so the
presets write `YYYY-MM-DD` there.

### With active_admin_datetimepicker

[active_admin_datetimepicker](https://github.com/activeadmin-plugins/active_admin_datetimepicker)
range filters (`filter :time_start, as: :date_time_range`) render as
`div.filter_date_time_range` on Active Admin 3 and 4. Init them by that
selector, the same way on both:

```javascript
ActiveAdminDateRangePreset.init('form div.filter_date_time_range');
```

On Active Admin 4 their inputs are `datetime-local` (or `date` for a date
column), so the presets write `YYYY-MM-DDTHH:MM` (or `YYYY-MM-DD`). In forms,
put `datetime_preset_pair` on the first picker's `wrapper_html` as for any
other pair.

### Custom inputs

The link goes into the first `label` of the element you init. When the inputs
are elsewhere on the page, point at them:

```javascript
ActiveAdminDateRangePreset.init('.any_selector', {
  gteq_input: '#date_from',
  lteq_input: '#date_to'
});
```

Calling `init` again on the same element replaces its setup, so a call with
options after the automatic one wins.

### Test hooks

The "Set range" link carries `data-date-range-preset-toggle`, the menu
`data-date-range-preset-menu`, and each preset `data-date-range-preset` with its
key: `today`, `yesterday`, `week`, `month`, `last_week`, `last_month`, then
`custom_0`, `custom_1`, ... for `add_range` entries.

## Settings

Pass settings to `init` for some elements, or set them for every later `init`
on `ActiveAdminDateRangePreset.defaults`. Set defaults before the page finishes
loading, since pairs are set up on `DOMContentLoaded`.

```javascript
// End date is the same day, not the next one.
// Today true : 2015-06-12 - 2015-06-12
// Today false: 2015-06-12 - 2015-06-13
ActiveAdminDateRangePreset.defaults.date_to_human_readable = true;

// Text inputs get the time too: 2015-06-12 00:00:00 - 2015-06-13 00:00:00
ActiveAdminDateRangePreset.defaults.show_time = true;
```

### date_to_human_readable

value: true/false

default: false

This options changes second date to include full date-time of the day, like normal human thinks about time ranges.
Today true : 2015-06-12 - 2015-06-12
Today false: 2015-06-12 - 2015-06-13

When normal human say "2015-06-12" hi means "2015-06-12 23:59:59"
But default behavior in programming is "2015-06-12" = "2015-06-12 00:00:00"
Be careful with this options. Cause if you change it to "true" you will also need to change your server-side scripts to search "humanize-way".

### show_time

value: true/false

default: false

If true, text inputs get date and time, usually 00:00:00. Native inputs ignore
it: their `type` decides.

### hours_offset

values: positive or negative integer

default: 0

To work correctly this plugin needs to detect current date-time. And it uses UTC. But if you need your local timezone or some other time-shift, your can set this option:

```javascript
ActiveAdminDateRangePreset.defaults.hours_offset = +3;
// or
ActiveAdminDateRangePreset.defaults.hours_offset = -3;
```

### add_range

```javascript
ActiveAdminDateRangePreset.init('form.filter_form div.filter_date_range', {
  date_to_human_readable: true, // affects the end date
  add_range: [
    {
      title: 'Last 30 days',
      // date_to_human_readable moves the end date back a second, so end tomorrow:
      start: new Date(new Date().setDate(new Date().getDate() - 29)),
      end: new Date(new Date().setDate(new Date().getDate() + 1))
    }
  ]
});
```

## Development

The specs run against a throwaway Rails app built by `spec/support/rails_template.rb`.
It is generated automatically on the first run (or via `bundle exec rake setup`) into
`spec/rails/rails-<version>-aa<version>/`, which is gitignored.

```sh
bundle install
bundle exec rspec spec
```

Pick the versions under test with env vars. `AA=4.x` switches the bundle from
Sprockets to Propshaft, importmap-rails and Tailwind:

```sh
RAILS=8.0.0 AA=3.5.0 bundle install
RAILS=8.0.0 AA=3.5.0 bundle exec rspec spec
AA=4.0.0.beta23 bundle install
AA=4.0.0.beta23 bundle exec rspec spec
```
