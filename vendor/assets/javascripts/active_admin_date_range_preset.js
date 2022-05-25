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
    function formatDate(date) {
      let str = date.getFullYear() + '-' + num_with_leading_zero(date.getMonth()+1) + '-' + num_with_leading_zero(date.getDate());
      if (opts.show_time) {
        str += (' ' + num_with_leading_zero(date.getHours()) + ':' + num_with_leading_zero(date.getMinutes()) + ':' + num_with_leading_zero(date.getSeconds()));
      }
      return str;
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

      if (typeof $this.data('show-time') != 'undefined' && $this.data('show-time').toString() == 'true') {
        opts.show_time = true;
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
        gteq_input.val(formatDate(start));
        if (opts.date_to_human_readable) {
          end.setTime(end.getTime() - 1000);
        }

        lteq_input.val(formatDate(end));
      }

      $this.on('click', '.btn_timerange', function(e) {
        unbindClickEventBlockTimerange();
        e.stopPropagation();
        e.preventDefault();

        let additional_items_html = '';
        opts.add_range.forEach(function(el, i) {
          return additional_items_html += '<div><span class="btn_date_range_' + i + '">' + el['title'] + '</span></div>';
        });

        $('body').append('<div style="min-width: '+e.target.offsetWidth+'px; top: '+(e.target.offsetTop)+'px; left: '+(e.target.offsetLeft)+'px" class="block_timerange">' +
          '<div><span class="btn_today">Today</span></div>' +
          '<div><span class="btn_yesterday">Yesterday</span></div>' +
          '<div><span class="btn_week">This Week</span></div>' +
          '<div><span class="btn_month">This Month</span></div>' +
          '<div><span class="btn_last_week">Last Week</span></div>' +
          '<div><span class="btn_last_month">Last Month</span></div>' +
          additional_items_html +
          '</div>'
        ).ready(function() {
          let container = $(this).find('.block_timerange');

          // additional ranges
          opts.add_range.forEach(function(el, i) {
            $(container).on('click.CalendarRangeSet', '.btn_date_range_' + i, function(e) {
              unbindClickEventBlockTimerange();
              let start = new Date(el['start'].getFullYear(), el['start'].getMonth(), el['start'].getDate());
              let end = new Date(el['end'].getFullYear(), el['end'].getMonth(), el['end'].getDate());
              fillInputs(start, end)
            });
          });

          // Today
          $(container).on('click.CalendarRangeSet', '.btn_today', function(e) {
            unbindClickEventBlockTimerange();
            let start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate());
            let end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() + 1);
            fillInputs(start, end);
          });

          // Yesterday
          $(container).on('click.CalendarRangeSet', '.btn_yesterday', function(e) {
            unbindClickEventBlockTimerange();
            let start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - 1);
            let end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate());
            fillInputs(start, end);
          });

          // Week
          $(container).on('click.CalendarRangeSet', '.btn_week', function(e) {
            unbindClickEventBlockTimerange();
            let start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - datetime.getDay() + 1);
            let end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + 7);
            fillInputs(start, end);
          });

          // Month
          $(container).on('click.CalendarRangeSet', '.btn_month', function(e) {
            unbindClickEventBlockTimerange();
            let start = new Date(datetime.getFullYear(), datetime.getMonth(), 1);
            let end = new Date(datetime.getFullYear(), datetime.getMonth() + 1, 1);
            fillInputs(start, end);
          });

          // Last Week
          $(container).on('click.CalendarRangeSet', '.btn_last_week', function(e) {
            unbindClickEventBlockTimerange();
            let end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - datetime.getDay() + 1);
            let start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 7);
            fillInputs(start, end);
          });

          // Last Month
          $(container).on('click.CalendarRangeSet', '.btn_last_month', function(e) {
            unbindClickEventBlockTimerange();
            let end = new Date(datetime.getFullYear(), datetime.getMonth(), 1);
            let start = new Date(end.getFullYear(), end.getMonth() - 1, 1);
            fillInputs(start, end);
          });

          // Outer
          $('body').on('click.CalendarRangeSet', function(e) {
            e.stopPropagation();
            if ($(e.target).closest('.block_timerange').length == 0) {
              unbindClickEventBlockTimerange();
            }
          });
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

$(document).on('ready', function() {
  // Init in forms
  $('.datetime_preset_pair').date_range_ext_preset();
});
