require 'spec_helper'

describe 'date range preset', type: :feature, js: true do

  # The plugin builds its ranges from UTC, with hours_offset defaulting to 0.
  let(:today) { Time.now.utc.to_date }

  before { add_post_resource }

  context 'date_range filter in the sidebar' do
    before { visit '/admin/posts' }

    let(:filter) { page.find(PageHelpers::FILTER) }

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

      expect(range_in(filter)).to eq([today.strftime('%Y-%m-%d'), (today + 1).strftime('%Y-%m-%d')])
      expect(page).to have_no_css('.block_timerange')
    end

    it 'fills both inputs with yesterday' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_yesterday').click

      expect(range_in(filter)).to eq([(today - 1).strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d')])
    end

    it 'fills both inputs with this month' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_month').click

      expect(range_in(filter)).to eq([today.strftime('%Y-%m-01'), today.next_month.strftime('%Y-%m-01')])
    end

    it 'fills both inputs with this week, monday to monday' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_week').click

      monday = today - ((today.wday - 1) % 7)
      expect(range_in(filter)).to eq([monday.strftime('%Y-%m-%d'), (monday + 7).strftime('%Y-%m-%d')])
    end

    it 'filters the collection by the chosen range' do
      Post.create!(title: 'old', created_at: today - 10)
      Post.create!(title: 'fresh')

      visit '/admin/posts'
      page.find("#{PageHelpers::FILTER} a.btn_timerange").click
      page.find('.block_timerange .btn_today').click
      page.find('input[type="submit"]').click

      expect(page).to have_content('fresh')
      expect(page).to have_no_content('old')
    end
  end

  context 'datetime_preset_pair auto-init in a form' do
    before { visit '/admin/posts/new' }

    let(:pair) { page.find('.datetime_preset_pair') }

    it 'adds a "Set range" link to the first input of the pair' do
      expect(pair).to have_css('a.btn_timerange', text: /set range/i)
    end

    it 'fills the pair with today including time' do
      pair.find('a.btn_timerange').click
      page.find('.block_timerange .btn_today').click

      expect(pair.find('input[type="text"]').value)
        .to eq(today.strftime('%Y-%m-%d 00:00:00'))
    end
  end

  # active_admin_datetimepicker puts .datetime_preset_pair on a range filter
  # wrapper that holds both inputs, so the auto-init has to fill both of them.
  context 'datetime_preset_pair auto-init on a range filter' do
    before { visit '/admin/posts' }

    let(:filter) { page.find('#q_published_at_input') }

    it 'fills the first and last input of the wrapper' do
      filter.find('a.btn_timerange').click
      page.find('.block_timerange .btn_today').click

      expect(range_in(filter)).to eq([today.strftime('%Y-%m-%d'), (today + 1).strftime('%Y-%m-%d')])
    end
  end
end
