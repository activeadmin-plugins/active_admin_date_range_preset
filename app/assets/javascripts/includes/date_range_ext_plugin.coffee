(($) ->
  # options:
  #  inject_method: 'append' | 'append' how to insert new HTML into document
  #  gteq_input: jQuery-selecotr for input date_from
  #  lteq_input: jQuery-selecotr for input date_to
  #  hours_offset: Int number - hours +/- to correct time
  $.fn.date_range_ext = (options)->

    # settings
    options = options || {}
    inject_method = options.inject_method || 'wrap'
    hours_offset = options.hours_offset || 0
    show_time = options.show_time || false

    # datetime object, uses local user timeset, with offset.
    datetime = new Date((new Date()).getTime() + hours_offset * 60 * 60 * 1000)

    # formated date YYYY-MM-DD, with converting to UTC
    formatDate = (date, hh_mm_ss)->
      str = (date).toISOString().slice(0, 10)
      if show_time
        str += ' 00:00:00'
      return str

    unbindClickEventBlockTimerange = ->
      $('.block_timerange').remove()
      $('body').off('click.CalendarRangeSet')

    return this.each (i, el) ->
      # PLUGIN BEGIN

      $this = $(el)

      # helper variables
      if (options.lteq_input)
        lteq_input = $(options.lteq_input)
      else
        lteq_input = $this.find('input[id$=_lteq]')

      if options.gteq_input
        gteq_input = $(options.gteq_input)
      else
        gteq_input = $this.find('input[id$=_gteq]')

      fillInputs = (month_start, month_end)->
        gteq_input.val( formatDate(month_start) )
        lteq_input.val( formatDate(month_end, '23:59:59') )

      # filter modifying
      if inject_method == 'append'
        $this.append('<a href="#" class="btn_timerange">Set range</a>')
      else
        $this.find('label').wrap("<div class='label_div'></div>")
        $this.find('div.label_div').append('<a href="#" class="btn_timerange">Set range</a>')

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
            today_end = new Date(datetime)
            today_end.setDate( today_end.getDate() +  1 )
            fillInputs(datetime, today_end)
          )

          # Yesterday
          $(container).on('click.CalendarRangeSet', '.btn_yesterday', (e)->
            unbindClickEventBlockTimerange()
            yesterday_start = new Date(datetime)
            yesterday_start.setDate( yesterday_start.getDate() -  1 )

            fillInputs(yesterday_start, datetime)
          )

          # Week
          $(container).on('click.CalendarRangeSet', '.btn_week', (e)->
            unbindClickEventBlockTimerange()
            week_start = new Date(datetime)
            week_start.setDate( week_start.getDate() - week_start.getDay() + 1 )
            week_end = new Date(datetime)
            week_end.setTime( week_start.getTime() )
            week_end.setDate( week_start.getDate() + 7 )

            fillInputs(week_start, week_end)
          )

          # Month
          $(container).on('click.CalendarRangeSet', '.btn_month', (e)->
            unbindClickEventBlockTimerange()
            month_start = new Date(datetime)
            month_start.setDate(1)

            fillInputs(month_start, datetime)
          )

          # Last Week
          $(container).on('click.CalendarRangeSet', '.btn_last_week', (e)->
            unbindClickEventBlockTimerange()
            end = new Date(datetime)
            end.setDate( end.getDate() - end.getDay() + 1 )
            start = new Date(end)
            start.setDate( start.getDate() - 7 )

            fillInputs(start, end)
          )

          # Last Month
          $(container).on('click.CalendarRangeSet', '.btn_last_month', (e)->
            unbindClickEventBlockTimerange()
            end = new Date(datetime)
            end.setDate(1)
            start = new Date(end)
            start.setMonth( start.getMonth() - 1 )

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

) jQuery






#
# Example how to apply to different places with different options
#
#
$(document).on 'ready', ->
  $('form.filter_form div.filter_date_range').date_range_ext()

  $('form.filter_form div.filter_date_time_range').date_range_ext({
    show_time: true
  })

  #
  # main selector is where to put links
  # gteq_input and lteq_input is target inputs
  #
  $('li#report_supplier_traffic_date_from_input label, ' +
      'li#report_profitability_date_from_input label, ' +
      'li#report_customer_traffic_date_from_input label, ' +
      'li#report_disconnect_reason_date_from_input label').date_range_ext(
    {
      inject_method: 'append',
      show_time: true,
      gteq_input: 'input[id$=date_from]',
      lteq_input: 'input[id$=date_to]'
    }
  )
