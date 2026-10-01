require 'spec_helper'

describe 'initialising the same element twice', type: :feature, js: true do

  let(:today) { Time.now.utc.to_date }

  before { add_post_resource }
  before { visit '/admin/posts' }

  def filter
    page.find('.filter_date_range')
  end

  def init_again(options = '')
    page.execute_script(
      "$('form.filter_form div.filter_date_range').date_range_ext_preset(#{options});"
    )
  end

  # first, not find: with the bug there are two links, and an ambiguous-match
  # error would mask whatever the example is actually asserting.
  def pick_today
    page.first('.filter_date_range a.btn_timerange').click
    page.find('.block_timerange .btn_today').click
  end

  def chosen_range
    inputs = filter.all('input[type="text"]')
    [inputs.first.value, inputs.last.value]
  end

  # The auto-init was dead from jQuery 3 until it was restored, so the
  # workaround -- calling the plugin by hand in active_admin.js -- is what
  # host apps are carrying. Both run after an upgrade.
  context 'with no options' do
    before { init_again }

    it 'leaves one "Set range" link, not one per call' do
      expect(filter).to have_css('a.btn_timerange', count: 1)
    end

    it 'leaves one click handler, not one per call' do
      count = page.evaluate_script(
        "$._data($('form.filter_form div.filter_date_range')[0], 'events').click.length"
      )

      expect(count).to eq(1)
    end

    it 'still fills the inputs' do
      pick_today

      expect(chosen_range).to eq([today.strftime('%Y-%m-%d'),
                                  (today + 1).strftime('%Y-%m-%d')])
    end
  end

  # Sprockets puts the plugin's own ready callback ahead of anything the host
  # appends to active_admin.js, so a guard that kept the first wiring would
  # drop the host's configuration without a word.
  context 'when the second call passes options' do
    before { init_again('{ date_to_human_readable: true }') }

    it 'honours them instead of discarding them' do
      pick_today

      expect(chosen_range).to eq([today.strftime('%Y-%m-%d'),
                                  today.strftime('%Y-%m-%d')])
    end
  end
end
