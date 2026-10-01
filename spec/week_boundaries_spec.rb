require 'spec_helper'

describe 'week presets', type: :feature, js: true do

  before { add_post_resource }

  def open_presets
    page.find('.filter_date_range a.btn_timerange').click
  end

  def chosen_range
    inputs = page.find('.filter_date_range').all('input[type="text"]')
    [inputs.first.value, inputs.last.value]
  end

  # Midday UTC, so the runner's own offset cannot move the date.
  SUNDAY    = '2026-10-04T12:00:00Z'.freeze # end of the week starting 2026-09-28
  WEDNESDAY = '2026-09-30T12:00:00Z'.freeze # middle of the same week

  context 'on a Sunday' do
    before do
      freeze_browser_time(SUNDAY)
      visit '/admin/posts'
    end

    it 'offers the week Sunday belongs to, not the one starting the next day' do
      open_presets
      page.find('.block_timerange .btn_week').click

      expect(chosen_range).to eq(['2026-09-28', '2026-10-05'])
    end

    it 'offers the week before the one Sunday belongs to' do
      open_presets
      page.find('.block_timerange .btn_last_week').click

      expect(chosen_range).to eq(['2026-09-21', '2026-09-28'])
    end
  end

  context 'on a Wednesday' do
    before do
      freeze_browser_time(WEDNESDAY)
      visit '/admin/posts'
    end

    it 'offers the same week a Sunday in it would offer' do
      open_presets
      page.find('.block_timerange .btn_week').click

      expect(chosen_range).to eq(['2026-09-28', '2026-10-05'])
    end

    it 'offers the same previous week a Sunday in it would offer' do
      open_presets
      page.find('.block_timerange .btn_last_week').click

      expect(chosen_range).to eq(['2026-09-21', '2026-09-28'])
    end
  end
end
