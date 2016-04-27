# active_admin_date_range_preset

Preset links for ActiveAdmin date_range inputs in sidebar filters in forms

This is how it looks like

![Step 1](/screen/step_1.jpg)

![Step 2](/screen/step_2.jpg)

![Form 1](/screen/step_2_1.png)

![Form 2](/screen/step_2_2.png)

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
Main point is to set for first input-pair wrapper-class

```wrapper_html: { class: 'datetime_preset_pair' }```

input name('date_from' and 'date_to') can be named whatever your need

By default inputs are filled with date("yyyy-mm-dd"). If you need time add

```data: { show_time: 'true' }```


## Using with ActiveAdminDatetimepicker

If you use GEM https://github.com/activeadmin-plugins/active_admin_datetimepicker
and want apply this plugin to filter-inputs for this gem you need:

First apply ActiveAdminDatetimepicker to any filters your need

```ruby
filter :time_start, as: :date_time_range
```

In active_admin.js

Add following lines to JavaScript

```javascript
$(document).on('ready', function(){
    $('form.filter_form div.filter_date_time_range').date_range_ext_preset();
});
```

Now all you "date_time_range" inputs has button "Set rage"


## Custom usage

You can assign "Set range" almost to any input-text-pair filters/forms.
For example, you have complex form where input-pairs are not close to each other and not standard.

```javascript
$(document).on('ready', function(){
  $('.any_jquery_selector').date_range_ext_preset({
    lteq_input: '.jquery_selector_to_first_input',
    gteq_input: '.jquery_selector_to_second_input'
  });
});
```
".any_jquery_selector" is pointed to place where button "Set rage" will appear.
Set lteq_input and gteq_input to point to inputs if they not near main selector.


## Global and local settings

There are several settings, which can be set globally or locally.

Example how to set settings for only specific inputs

```javascript
$('.any_jquery_selector').date_range_ext_preset({
 setting_name: "setting_value"
});
```
Example how to set global settings. Write it before $(document).on('ready')

```javascript
$.fn.date_range_ext_preset.defaults.setting_name = "setting_value"
```

You can set global defaults in your active_admin.js like this:

```javascript
# End date will be full-day, not next.
# Today true : 2015-06-12 - 2015-06-12
# Today false: 2015-06-12 - 2015-06-13
$.fn.date_range_ext_preset.defaults.date_to_human_readable = true

# Display time
# Today: 2015-06-12 00:00:00 - 2015-06-13 00:00:00
# Today with human_readable=true: 2015-06-12 00:00:00 - 2015-16-12 23:59:59
$.fn.date_range_ext_preset.defaults.show_time = true
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

If true then will show date and time, usually it will be 00:00:00

### hours_offset

values: positive or negative integer

default: 0

To work correctly this plugin needs to detect current date-time. And it uses UTC. But if you need your local timezone or some other time-shift, your can set this option:

Example:
```javascript
$.fn.date_range_ext_preset.defaults.hours_offset = +3
// or
$.fn.date_range_ext_preset.defaults.hours_offset = -3
``` 

### Addition ranges

```javascript
$(document).on('ready', function(){

    $('.filter_form .filter_date_range').date_range_ext_preset({
        date_to_human_readable: true, # affects last day
        add_range: [
            {
                title: 'Last 30 days',
                // date_to_human_readable affects end-date, sow must do this:
                start: new Date(new Date().setDate(new Date().getDate() - 29)),
                end: new Date(new Date().setDate(new Date().getDate() + 1))
            }
        ]
    });

});
```
