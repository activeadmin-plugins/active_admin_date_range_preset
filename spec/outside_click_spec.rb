require 'spec_helper'

describe 'clicking outside the preset popup', type: :feature, js: true do

  before { add_post_resource }
  before { visit '/admin/posts' }

  def open_presets
    page.find('.filter_date_range a.btn_timerange').click
  end

  def apply_todays_range
    open_presets
    page.find('.block_timerange .btn_today').click
    page.find('input[type="submit"]').click
  end

  # The popup dismissal listener sits on <body>, in the path of every click
  # Active Admin delegates from <document>: Clear Filters, has_many add and
  # has_many remove are all bound there.
  it 'still lets Active Admin handle the same click' do
    apply_todays_range
    expect(page).to have_current_path(/q(%5B|%5b|\[)/)

    open_presets
    page.find('.clear_filters_btn').click

    # _clearForm drops the q[...] params and keeps the rest, so assert on
    # the filter params alone rather than on a bare path.
    expect(page).to have_no_current_path(/q(%5B|%5b|\[)/)
    expect(page).to have_no_css('.block_timerange')
  end
end
