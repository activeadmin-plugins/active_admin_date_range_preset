require 'spec_helper'

describe 'initialising the same element twice', type: :feature, js: true do

  let(:today) { Time.now.utc.to_date }

  before { add_post_resource }
  before { visit '/admin/posts' }

  def filter
    page.find(PageHelpers::FILTER)
  end

  def init_again(options = '{}')
    page.execute_script(
      "ActiveAdminDateRangePreset.init('#{PageHelpers::FILTER}', #{options});"
    )
  end

  # first, not find: with the bug there are two links, and an ambiguous-match
  # error would mask whatever the example is actually asserting.
  def pick_today
    page.first("#{PageHelpers::FILTER} a.btn_timerange").click
    page.find('.block_timerange .btn_today').click
  end

  # The dummy app already initialises the filter once, so these examples see
  # a second call on the same element.
  context 'with no options' do
    before { init_again }

    it 'leaves one "Set range" link, not one per call' do
      expect(filter).to have_css('a.btn_timerange', count: 1)
    end

    it 'opens one menu, not one per call' do
      page.first("#{PageHelpers::FILTER} a.btn_timerange").click

      expect(page).to have_css('.block_timerange', count: 1)
    end

    it 'still fills the inputs' do
      pick_today

      expect(range_in(filter)).to eq([today.strftime('%Y-%m-%d'), (today + 1).strftime('%Y-%m-%d')])
    end
  end

  # A guard that kept the first wiring would drop the host's configuration
  # without a word.
  context 'when the second call passes options' do
    before { init_again('{ date_to_human_readable: true }') }

    it 'honours them instead of discarding them' do
      pick_today

      expect(range_in(filter)).to eq([today.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d')])
    end
  end
end
