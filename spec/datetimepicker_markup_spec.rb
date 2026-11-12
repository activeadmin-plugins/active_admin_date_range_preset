require 'spec_helper'

# The range filter markup active_admin_datetimepicker renders on Active Admin
# 4, injected as-is so the spec does not depend on that gem.
describe 'active_admin_datetimepicker range filters', type: :feature, js: true do

  WEDNESDAY_NOON_UTC = '2026-09-30T12:00:00Z'.freeze

  before do
    add_post_resource
    freeze_browser_time(WEDNESDAY_NOON_UTC)
    visit '/admin/posts'
  end

  def inject_filter(id, type, attr)
    suffix = type == 'date' ? '' : '_datetime_picker'
    page.execute_script(<<~JS)
      var form = document.querySelector('form');
      form.insertAdjacentHTML('afterbegin',
        '<div id="#{id}" class="filter_date_time_range" data-datetimepicker-range="true">' +
        '<label>#{attr}</label><div class="filters-form-input-group">' +
        '<input type="#{type}" name="q[#{attr}_gteq#{suffix}]" data-datetimepicker-range-input="from">' +
        '<input type="#{type}" name="q[#{attr}_lteq#{suffix}]" data-datetimepicker-range-input="to">' +
        '</div></div>');
      ActiveAdminDateRangePreset.init('##{id}');
    JS
  end

  def pick_today(id)
    page.find("##{id} [data-date-range-preset-toggle]").click
    page.find("[data-date-range-preset-menu] [data-date-range-preset='today']").click
  end

  def range(id)
    %w[from to].map { |bound| page.find("##{id} [data-datetimepicker-range-input='#{bound}']").value }
  end

  it 'fills datetime-local inputs with YYYY-MM-DDTHH:MM' do
    inject_filter('dtp_datetime', 'datetime-local', 'published_at')
    pick_today('dtp_datetime')

    expect(range('dtp_datetime')).to eq(['2026-09-30T00:00', '2026-10-01T00:00'])
  end

  it 'fills date inputs of a date column with YYYY-MM-DD' do
    inject_filter('dtp_date', 'date', 'published_on')
    pick_today('dtp_date')

    expect(range('dtp_date')).to eq(['2026-09-30', '2026-10-01'])
  end
end
