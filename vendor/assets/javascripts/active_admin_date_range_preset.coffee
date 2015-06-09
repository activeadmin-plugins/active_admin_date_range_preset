(($) ->
  # options:
  #  inject_method: 'append' | 'append' how to insert new HTML into document
  #  gteq_input: jQuery-selecotr for input date_from
  #  lteq_input: jQuery-selecotr for input date_to
  #  hours_offset: Int number - hours +/- to correct time
  $.fn.date_range_ext_preset = (options)->

    # settings
    options = options || {}
    opts = $.extend( {}, $.fn.date_range_ext_preset.defaults, options );

    # aditional functions
    num_with_leading_zero = (num, digits_count = 2)->
      s = num + ''
      s = '0' + s while (s.length < digits_count)
      return s

    # formated date YYYY-MM-DD, with converting to UTC
    formatDate = (date)->
      str = date.getFullYear() + '-' + num_with_leading_zero(date.getMonth()) + '-' + num_with_leading_zero(date.getDate())
      if opts.show_time
        str += ( ' ' + num_with_leading_zero(date.getHours()) + ':' + num_with_leading_zero(date.getMinutes()) + ':' + num_with_leading_zero(date.getSeconds()) )
      return str

    unbindClickEventBlockTimerange = ->
      $('.block_timerange').remove()
      $('body').off('click.CalendarRangeSet')

    # local datetime now
    now = new Date()
    # UTC datetime now
    now_utc = new Date(
      now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),
      now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds(),
      now.getUTCMilliseconds()
    )
    # datetime object, UTC with hours offset
    datetime = new Date(now_utc.getTime() + opts.hours_offset * 60 * 60 * 1000)


    # PLUGIN BEGIN
    return this.each (i, el) ->
      $this = $(el)

      if $this.data('show-time').toString() == 'true'
        console.log $this.data('show-time')
        opts.show_time = true


      # detect inputs
      if options.lteq_input
        lteq_input = $(options.lteq_input)
      else
        lteq_input = if $this.hasClass('datetime_preset_pair') then $this.next().find('input') else $this.find('input[id$=_lteq]')
      if options.gteq_input
        gteq_input = $(options.gteq_input)
      else
        gteq_input = if $this.hasClass('datetime_preset_pair') then $this.find('input') else $this.find('input[id$=_gteq]')

      # filter modifying
      main_btn_html = '<a href="#" class="btn_timerange">Set range</a>'
      if opts.inject_method == 'append'
        $this.append(main_btn_html)
      else
        $this.find('label').addClass('datetime_preset_filter_label').append(main_btn_html)

      # helper
      fillInputs = (start, end)->
        gteq_input.val(formatDate(start) )
        if opts.date_to_human_readable
          end.setTime( end.getTime() - 1000 )
        lteq_input.val( formatDate(end) )

      $this.on('click', '.btn_timerange', (e)->
        unbindClickEventBlockTimerange()
        e.stopPropagation()
        e.preventDefault()
        $('body').append('<div style="min-width: '+e.target.offsetWidth+'px; top: '+(e.target.offsetTop)+'px; left: '+(e.target.offsetLeft)+'px" class="block_timerange">' +
            '<div><span class="btn_today">Today</span></div>' +
            '<div><span class="btn_yesterday">Yesterday</span></div>' +
            '<div><span class="btn_week">This Week</span></div>' +
            '<div><span class="btn_month">This Month</span></div>' +
            '<div><span class="btn_last_week">Last Week</span></div>' +
            '<div><span class="btn_last_month">Last Month</span></div>' +
            '</div>'
        ).ready(->
          container = $(this).find('.block_timerange')

          # Today
          $(container).on('click.CalendarRangeSet', '.btn_today', (e)->
            unbindClickEventBlockTimerange()
            start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate())
            end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() + 1)
            fillInputs(start, end)
          )

          # Yesterday
          $(container).on('click.CalendarRangeSet', '.btn_yesterday', (e)->
            unbindClickEventBlockTimerange()
            start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - 1)
            end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate())
            fillInputs(start, end)
          )

          # Week
          $(container).on('click.CalendarRangeSet', '.btn_week', (e)->
            unbindClickEventBlockTimerange()
            start = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - datetime.getDay() + 1)
            end = new Date(start.getFullYear(), start.getMonth(), start.getDate() + 7)
            fillInputs(start, end)
          )

          # Month
          $(container).on('click.CalendarRangeSet', '.btn_month', (e)->
            unbindClickEventBlockTimerange()
            start = new Date(datetime.getFullYear(), datetime.getMonth(), 1)
            end = new Date(datetime.getFullYear(), datetime.getMonth()+1, 1)
            fillInputs(start, end)
          )

          # Last Week
          $(container).on('click.CalendarRangeSet', '.btn_last_week', (e)->
            unbindClickEventBlockTimerange()
            end = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate() - datetime.getDay() + 1)
            start = new Date(end.getFullYear(), end.getMonth(), end.getDate() - 7)
            fillInputs(start, end)
          )

          # Last Month
          $(container).on('click.CalendarRangeSet', '.btn_last_month', (e)->
            unbindClickEventBlockTimerange()
            end = new Date(datetime.getFullYear(), datetime.getMonth(), 1)
            start = new Date(end.getFullYear(), end.getMonth() - 1, 1)
            fillInputs(start, end)
          )

          # Outer
          $('body').on('click.CalendarRangeSet', (e)->
            e.stopPropagation()
            if $(e.target).closest('.block_timerange').length == 0
              unbindClickEventBlockTimerange()
          )
        )
      )

  $.fn.date_range_ext_preset.defaults = {
    inject_method: 'wrap',
    # Manual global time shift, from UTC can be +/- number
    hours_offset: 0,
    # date_to_human_readable = true, then "date_to" consider as including full day without last second
    #  For example Today will be:
    #   true
    #     2015-06-10 - 2015-06-10
    #     2015-06-10 00:00:00 - 2015-06-10 23:59:59
    #   false
    #     2015-06-10 - 2015-06-11
    #     2015-06-10 00:00:00 - 2015-06-11 00:00:00
    date_to_human_readable: false,
    # Display time or not: 2015-06-10 vs 2015-06-10 00:00:00
    show_time: false
  };

) jQuery




$(document).on 'ready', ->
  # Init in sidebar filters
  $('.filter_form .filter_date_range').date_range_ext_preset()
  # Init in forms
  $('.datetime_preset_pair').date_range_ext_preset({inject_method: 'append'})
