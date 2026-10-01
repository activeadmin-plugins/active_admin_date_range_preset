$(function () {
  // options:
  //  gteq_input: jQuery-selecotr for input date_from
  //  lteq_input: jQuery-selecotr for input date_to
  //  hours_offset: Int number - hours +/- to correct time
  $.fn.date_range_ext_preset = function(options) {
    // settings
    options = options || {};
    let opts = $.extend({}, $.fn.date_range_ext_preset.defaults, options);

    // aditional functions
    function num_with_leading_zero(num, digitsCount = 2) {
      let s = num + '';
      while (s.length < digitsCount) {
        s = '0' + s;
      }
      return s;
    }

    // formated date YYYY-MM-DD, with converting to UTC
    // note: getMonth Returns the month (from 0-11), so we do +1
    function formatDate(date, el_opts) {
      let str = date.getFullYear() + '-' + num_with_leading_zero(date.getMonth()+1) + '-' + num_with_leading_zero(date.getDate());
      if (el_opts.show_time) {
        str += (' ' + num_with_leading_zero(date.getHours()) + ':' + num_with_leading_zero(date.getMinutes()) + ':' + num_with_leading_zero(date.getSeconds()));
      }
      return str;
    }

    // Days from the Monday that opens this date's week. getDay() counts from
    // Sunday, so a plain `- getDay() + 1` lands on tomorrow for Sundays and
    // hands back the week that has not started yet.
    function days_since_monday(date) {
      return (date.getDay() + 6) % 7;
    }

    function unbindClickEventBlockTimerange() {
      $('.block_timerange').remove();
      $('body').off('click.CalendarRangeSet');
    }

    // local datetime now
    let now = new Date();
    // UTC datetime now
    let now_utc = new Date(
      now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),
      now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds(),
      now.getUTCMilliseconds()
    );
    // datetime object, UTC with hours offset
    let datetime = new Date(now_utc.getTime() + opts.hours_offset * 60 * 60 * 1000);

    // PLUGIN BEGIN
    return this.each(function(i, el) {
      let $this = $(el);

      // Re-initialising an element replaces its wiring instead of adding to
      // it. The auto-init below was dead from jQuery 3 onwards, so hosts
      // worked around it by calling the plugin themselves; now that it works
      // again both run, and without this the label grows a second "Set range"
      // whose handler tears down the first one's popup.
      //
      // Replacing rather than skipping matters: the auto-init registers its
      // ready callback before anything a host adds to active_admin.js, so
      // bailing out on the second call would silently drop the host's
      // options. Reading the link itself rather than a data flag keeps the
      // guard and the thing it guards from drifting apart across clone() and
      // Turbo cache restores, which copy the node but not jQuery's data.
      $this.find('a.btn_timerange').remove();
      $this.off('click.dateRangeExtPreset');

      // Per element, because data-show-time is read off the element itself.
      // Writing it back into the shared opts let one pair's setting reach
      // every other pair in the same call, and formatDate reads the flag at
      // click time rather than here, so the leak was not even order-dependent.
      let el_opts = $.extend({}, opts);

      // The attribute is authoritative in both directions when present. Only
      // ever assigning true made it impossible for one element to opt out of
      // a show_time the call or the defaults had turned on.
      if (typeof $this.data('show-time') != 'undefined') {
        el_opts.show_time = $this.data('show-time').toString() == 'true';
      }

      // detect inputs
      let lteq_input = $this.find('input:last');
      if (options.lteq_input) {
        lteq_input = $(options.lteq_input);
      } else if ($this.hasClass('datetime_preset_pair')) {
        lteq_input = $this.next().find('input');
      }

      let gteq_input = $this.find('input:first');
      if (options.gteq_input) {
        gteq_input = $(options.gteq_input);
      } else if ($this.hasClass('datetime_preset_pair')) {
        gteq_input = $this.find('input');
      }

      // filter modifying
      let main_btn_html = '<a href="#" class="btn_timerange">Set range</a>';
      $this.find('label').addClass('datetime_preset_filter_label').append(main_btn_html);

      // helper
      function fillInputs(start, end) {
        gteq_input.val(formatDate(start, el_opts));
        if (el_opts.date_to_human_readable) {
          end.setTime(end.getTime() - 1000);
        }

        lteq_input.val(formatDate(end, el_opts));
      }

      $this.on('click.dateRangeExtPreset', '.btn_timerange', function(e) {
        unbindClickEventBlockTimerange();
        e.stopPropagation();
        e.preventDefault();

        let additional_items_html = '';
        opts.add_range.forEach(function(el, i) {
          return additional_items_html += '<div><span class="btn_date_range_' + i + '">' + el['title'] + '</span></div>';
        });

        // Bind in the same tick the popup is appended. Active Admin 3 ships
        // jQuery 3, which rebuilt .ready() on top of a Deferred whose .then
        // schedules through setTimeout, so handlers attached inside it landed
        // a macrotask late and the popup was on screen but inert until then.
        // On a non-document collection the method is deprecated anyway.
        let container = $('<div style="min-width: '+e.target.offsetWidth+'px; top: '+(e.target.offsetTop)+'px; left: '+(e.target.offsetLeft)+'px" class="block_timerange">' +
          '<div><span class="btn_today">Today</span></div>' +
          '<div><span class="btn_yesterday">Yesterday</span></div>' +
          '<div><span class="btn_week">This Week</span></div>' +
          '<div><span class="btn_month">This Month</span></div>' +
          '<div><span class="btn_last_week">Last Week</span></div>' +
          '<div><span class="btn_last_month">Last Month</span></div>' +
          additional_items_html +
          '</div>'
        ).appendTo('body');

        // additional ranges
        opts.add_range.forEach(function(el, i) {
          container.on('click.CalendarRangeSet', '.btn_date_range_' + i, function(e) {
            unbindClickEventBlockTimerange();
            let start = new Date(el['start'].getFullYear(), el['start'].getMonth(), el['start'].getDate());
            let end = new Date(el['end'].getFullYear(), el['end'].getMonth(), el['end'].getDate());
            fillInputs(start, end)
          });
        });

        // Today
        container.on('click.CalendarRangeSet', '.btn_today', function(e) {
          unbindClickEventBlockTimerange();
          let start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate());
          let end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() + 1);
          fillInputs(start, end);
        });

        // Yesterday
        container.on('click.CalendarRangeSet', '.btn_yesterday', function(e) {
          unbindClickEventBlockTimerange();
          let start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - 1);
          let end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate());
          fillInputs(start, end);
        });

        // Week
        container.on('click.CalendarRangeSet', '.btn_week', function(e) {
          unbindClickEventBlockTimerange();
          let start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - days_since_monday(datetime));
          let end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + 7);
          fillInputs(start, end);
        });

        // Month
        container.on('click.CalendarRangeSet', '.btn_month', function(e) {
          unbindClickEventBlockTimerange();
          let start = new Date(datetime.getFullYear(), datetime.getMonth(), 1);
          let end = new Date(datetime.getFullYear(), datetime.getMonth() + 1, 1);
          fillInputs(start, end);
        });

        // Last Week
        container.on('click.CalendarRangeSet', '.btn_last_week', function(e) {
          unbindClickEventBlockTimerange();
          let end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - days_since_monday(datetime));
          let start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 7);
          fillInputs(start, end);
        });

        // Last Month
        container.on('click.CalendarRangeSet', '.btn_last_month', function(e) {
          unbindClickEventBlockTimerange();
          let end = new Date(datetime.getFullYear(), datetime.getMonth(), 1);
          let start = new Date(end.getFullYear(), end.getMonth() - 1, 1);
          fillInputs(start, end);
        });

        // Outer
        // No stopPropagation here: this listener only watches for a click
        // that should close the popup. Active Admin delegates Clear Filters
        // and the has_many buttons from <document>, which is upstream of
        // <body>, so swallowing the event would break them for as long as
        // the popup is open.
        $('body').on('click.CalendarRangeSet', function(e) {
          if ($(e.target).closest('.block_timerange').length == 0) {
            unbindClickEventBlockTimerange();
          }
        });
      });
    });
  }

  $.fn.date_range_ext_preset.defaults = {
    // Manual global time shift, from UTC can be +/- number
    hours_offset: 0,

    // date_to_human_readable = true, then "date_to" consider as including full day without last second
    //  For example Today will be:
    //   true
    //     2015-06-10 - 2015-06-10
    //     2015-06-10 00:00:00 - 2015-06-10 23:59:59
    //   false
    //     2015-06-10 - 2015-06-11
    //     2015-06-10 00:00:00 - 2015-06-11 00:00:00
    date_to_human_readable: false,

    // Display time or not: 2015-06-10 vs 2015-06-10 00:00:00
    show_time: false,

    // Array of addition ranges
    // example:
    // {
    //   title: 'Last 30 days',
    //   start: new Date().setDate((new Date()).getDate() - 30)
    //   end: new Date()
    // }
    add_range: []
  }
});

// jQuery 3 removed $(document).on('ready'), so this must stay $(fn).
$(function() {
  // Init in forms
  $('.datetime_preset_pair').date_range_ext_preset();
});
