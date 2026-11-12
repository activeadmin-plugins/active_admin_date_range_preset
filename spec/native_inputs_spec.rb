require 'spec_helper'

# Native pickers only accept ISO values; anything else leaves them empty.
describe 'native date and datetime-local inputs', type: :feature, js: true do

  # Midday UTC, so the runner's own offset cannot move the date.
  WEDNESDAY_NOON = '2026-09-30T12:00:00Z'.freeze

  before do
    add_post_resource_with_native_pickers
    freeze_browser_time(WEDNESDAY_NOON)
    visit '/admin/posts/new'
  end

  def pick(wrapper_id, preset)
    page.find("##{wrapper_id} [data-date-range-preset-toggle]").click
    page.find("[data-date-range-preset-menu] [data-date-range-preset='#{preset}']").click
  end

  def value_of(wrapper_id)
    page.find("##{wrapper_id} input").value
  end

  it 'writes YYYY-MM-DDTHH:MM into datetime-local inputs' do
    pick('post_published_at_input', 'today')

    expect(value_of('post_published_at_input')).to eq('2026-09-30T00:00')
    expect(value_of('post_created_at_input')).to eq('2026-10-01T00:00')
  end

  it 'writes YYYY-MM-DD into date inputs' do
    pick('post_updated_at_input', 'week')

    expect(value_of('post_updated_at_input')).to eq('2026-09-28')
    expect(value_of('post_title_input')).to eq('2026-10-05')
  end

  it 'keeps the end of a human-readable range on the same day' do
    page.execute_script(
      "ActiveAdminDateRangePreset.init('#post_published_at_input', { date_to_human_readable: true });"
    )
    pick('post_published_at_input', 'today')

    expect(value_of('post_created_at_input')).to eq('2026-09-30T23:59')
  end
end

describe 'test hooks and dark mode', type: :feature, js: true do
  before do
    add_post_resource
    visit '/admin/posts'
    page.find("#{PageHelpers::FILTER} [data-date-range-preset-toggle]").click
  end

  it 'marks the menu and every preset with data attributes' do
    menu = page.find('[data-date-range-preset-menu]')
    keys = menu.all('[data-date-range-preset]').map { |item| item['data-date-range-preset'] }

    expect(keys).to eq(%w[today yesterday week month last_week last_month])
  end

  it 'darkens the menu under the .dark class' do
    background = lambda do
      page.evaluate_script(
        "getComputedStyle(document.querySelector('[data-date-range-preset-menu]')).backgroundColor"
      )
    end

    expect(background.call).to eq('rgb(244, 244, 244)')
    page.execute_script("document.documentElement.classList.add('dark')")
    expect(background.call).to eq('rgb(31, 41, 55)')
  end
end
