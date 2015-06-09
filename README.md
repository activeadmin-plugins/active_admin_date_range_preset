# active_admin_date_range_preset

Preset links for ActiveAdmin date_range inputs in sidebar filters in forms

This is how it looks like

![Step 1](/screen/step_1.jpg)

![Step 2](/screen/step_2.jpg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_admin_date_range_preset', github: 'workgena/active_admin_date_range_preset'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_admin_date_range_preset

Include assests:

 JS asset
 ```//= require active_admin_date_range_preset```

 CSS
 ```@import "active_admin_date_range_preset";```

Your sidebar filters should now have link "Set Range"

## Usage

in New/Edit formtastic forms:

```ruby
f.input :date_from, as: :date_time_picker, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
f.input :date_to, as: :date_time_picker
```

Input can be "as :string" or any other type compatible with "input type=text"
Main point is to set for ferst input-pair wrapper-class

```wrapper_html: { class: 'datetime_preset_pair' }```

input name('date_from' and 'date_to') can be named whatever your need

By default inputs fills with only date("2015-06-12"). If you need time add

```data: { show_time: 'true' }```


You can set global defaults in your active_admin.js like this:

```javascript
# End date will be full-day, not next.
# Today true : 2015-06-12 - 2015-06-12
# Today false: 2015-06-12 - 2015-06-13
$.fn.date_range_ext_preset.defaults.date_to_human_readable = true

# Displa time
# Today: 2015-06-12 00:00:00 - 2015-06-13 00:00:00
# Today with human_readable=true: 2015-06-12 00:00:00 - 2015-16-12 23:59:59
$.fn.date_range_ext_preset.defaults.show_time = true
```

Set dafaults before $(document).on('ready')
