require 'spec_helper'

describe 'keyboard, late defaults and lone inputs', type: :feature, js: true do

  let(:today) { Time.now.utc.to_date }

  before { add_post_resource }

  def active_preset
    page.evaluate_script("document.activeElement.getAttribute('data-date-range-preset')")
  end

  def toggle_focused?(scope)
    page.evaluate_script(
      "document.activeElement === document.querySelector('#{scope} [data-date-range-preset-toggle]')"
    )
  end

  context 'in the filter sidebar' do
    before { visit '/admin/posts' }

    let(:filter) { page.find(PageHelpers::FILTER) }

    it 'focuses the first preset, moves with arrows and picks with Enter' do
      filter.find('[data-date-range-preset-toggle]').click
      expect(active_preset).to eq('today')

      page.send_keys(:down)
      expect(active_preset).to eq('yesterday')

      page.send_keys(:enter)
      expect(page).to have_no_css('[data-date-range-preset-menu]')
      expect(range_in(filter)).to eq([(today - 1).strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d')])
      expect(toggle_focused?(PageHelpers::FILTER)).to be(true)
    end

    it 'closes on Escape and returns focus to the link' do
      filter.find('[data-date-range-preset-toggle]').click
      page.send_keys(:escape)

      expect(page).to have_no_css('[data-date-range-preset-menu]')
      expect(toggle_focused?(PageHelpers::FILTER)).to be(true)
    end

    it 'starts from the last preset on ArrowUp when no preset has focus' do
      filter.find('[data-date-range-preset-toggle]').click
      page.execute_script('document.activeElement.blur();')
      page.execute_script(<<~JS)
        document.querySelector('[data-date-range-preset-menu]')
          .dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowUp', bubbles: true }));
      JS

      expect(active_preset).to eq('last_month')
    end

    it 'closes when focus tabs out of the menu' do
      filter.find('[data-date-range-preset-toggle]').click
      page.execute_script("document.querySelector('[data-date-range-preset=\"last_month\"]').focus();")
      page.execute_script("document.querySelector('form input:not([type=\"hidden\"])').focus();")

      expect(page).to have_no_css('[data-date-range-preset-menu]')
    end

    it 'reads a defaults object the host replaced' do
      page.execute_script(<<~JS)
        ActiveAdminDateRangePreset.defaults = Object.assign({}, ActiveAdminDateRangePreset.defaults,
          { date_to_human_readable: true });
      JS
      auto = page.find('#q_published_at_input')
      auto.find('[data-date-range-preset-toggle]').click
      page.find("[data-date-range-preset-menu] [data-date-range-preset='today']").click

      expect(range_in(auto)).to eq([today.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d')])
    end

    # On Active Admin 4 the module, and its auto-init, runs before a host
    # module that imports it, so defaults are set after the pairs are wired.
    it 'applies defaults set after the automatic init' do
      page.execute_script('ActiveAdminDateRangePreset.defaults.date_to_human_readable = true;')
      auto = page.find('#q_published_at_input')
      auto.find('[data-date-range-preset-toggle]').click
      page.find("[data-date-range-preset-menu] [data-date-range-preset='today']").click

      expect(range_in(auto)).to eq([today.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d')])
    end
  end

  it 'fills only the start of a pair whose partner has no input' do
    visit '/admin/posts'
    page.execute_script(<<~JS)
      document.querySelector('form').insertAdjacentHTML('afterbegin',
        '<div id="lone" class="datetime_preset_pair"><label>Lone</label><input type="text" id="lone_input"></div><div></div>');
      ActiveAdminDateRangePreset.init('#lone');
    JS
    page.find('#lone [data-date-range-preset-toggle]').click
    page.find("[data-date-range-preset-menu] [data-date-range-preset='today']").click

    expect(page.find('#lone_input').value).to eq(today.strftime('%Y-%m-%d'))
  end

  it 'leaves the next field alone for an element that is not a pair' do
    visit '/admin/posts'
    page.execute_script(<<~JS)
      document.querySelector('form').insertAdjacentHTML('afterbegin',
        '<div id="single"><label>Single</label><input type="text" id="single_input"></div>' +
        '<div><input type="text" id="unrelated"></div>');
      ActiveAdminDateRangePreset.init('#single');
    JS
    page.find('#single [data-date-range-preset-toggle]').click
    page.find("[data-date-range-preset-menu] [data-date-range-preset='today']").click

    expect(page.find('#unrelated').value).to eq('')
  end
end
