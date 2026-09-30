require 'spec_helper'

describe 'date range preset', type: :feature, js: true do

  # The plugin builds its ranges from UTC, with hours_offset defaulting to 0.
  let(:today) { Time.now.utc.to_date }

  before { add_post_resource }

  def preset_inputs(scope)
    inputs = scope.all('input[type="text"]')
    [inputs.first, inputs.last]
  end

  context 'date_range filter in the sidebar' do
    before { visit '/admin/posts' }

    let(:filter) { page.find('.filter_date_range') }

    it 'adds a "Set range" link to the filter label' do
      expect(filter).to have_css('label.datetime_preset_filter_label a.btn_timerange', text: /set range/i)
    end

    it 'opens the preset popup with every range' do
      filter.find('a.btn_timerange').click

      popup = page.find('.block_timerange')
      expect(popup).to have_css('.btn_today', text: 'Today')
      expect(popup).to have_css('.btn_yesterday', text: 'Yesterday')
      expect(popup).to have_css('.btn_week', text: 'This Week')
      expect(popup).to have_css('.btn_month', text: 'This Month')
      expect(popup).to have_css('.btn_last_week', text: 'Last Week')
      expect(popup).to have_css('.btn_last_month', text: 'Last Month')
    end

    it 'closes the popup when clicking outside of it' do
      filter.find('a.btn_timerange').click
      expect(page).to have_css('.block_timerange')

      page.find('body').click
      expect(page).to have_no_css('.block_timerange')
    end

    it 'fills both inputs with today' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_today').click

      gteq, lteq = preset_inputs(filter)
      expect(gteq.value).to eq(today.strftime('%Y-%m-%d'))
      expect(lteq.value).to eq((today + 1).strftime('%Y-%m-%d'))
      expect(page).to have_no_css('.block_timerange')
    end

    it 'fills both inputs with yesterday' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_yesterday').click

      gteq, lteq = preset_inputs(filter)
      expect(gteq.value).to eq((today - 1).strftime('%Y-%m-%d'))
      expect(lteq.value).to eq(today.strftime('%Y-%m-%d'))
    end

    it 'fills both inputs with this month' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_month').click

      gteq, lteq = preset_inputs(filter)
      expect(gteq.value).to eq(today.strftime('%Y-%m-01'))
      expect(lteq.value).to eq((today.next_month).strftime('%Y-%m-01'))
    end

    it 'fills both inputs with this week, monday to monday' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_week').click

      monday = today - ((today.wday - 1) % 7)
      gteq, lteq = preset_inputs(filter)
      expect(gteq.value).to eq(monday.strftime('%Y-%m-%d'))
      expect(lteq.value).to eq((monday + 7).strftime('%Y-%m-%d'))
    end

    it 'filters the collection by the chosen range' do
      Post.create!(title: 'old', created_at: today - 10)
      Post.create!(title: 'fresh')

      visit '/admin/posts'
      page.find('.filter_date_range a.btn_timerange').click
      page.find('.block_timerange .btn_today').click
      page.find('input[type="submit"]').click

      expect(page).to have_content('fresh')
      expect(page).to have_no_content('old')
    end
  end
end
