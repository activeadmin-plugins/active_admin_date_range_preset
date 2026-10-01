require 'spec_helper'

describe 'binding the preset handlers', type: :feature, js: true do

  let(:today) { Time.now.utc.to_date }

  before { add_post_resource }
  before { visit '/admin/posts' }

  def gteq_value
    page.find('.filter_date_range').all('input[type="text"]').first.value
  end

  # Both clicks happen in one task, so the preset is clicked in the same tick
  # the popup was appended. Anything deferred to the next tick is not bound
  # yet and the click lands on nothing.
  # Wait for the link through Capybara first, otherwise a page that has not
  # finished rendering fails as a JS TypeError instead of an assertion.
  before { page.find('.filter_date_range a.btn_timerange') }

  it 'has the presets live as soon as the popup is in the document' do
    page.execute_script(<<~JS)
      var btn = document.querySelector('.filter_date_range a.btn_timerange');
      btn.click();
      document.querySelector('.block_timerange .btn_today').click();
    JS

    expect(gteq_value).to eq(today.strftime('%Y-%m-%d'))
  end

  it 'has the dismissal listener live just as soon' do
    page.execute_script(<<~JS)
      document.querySelector('.filter_date_range a.btn_timerange').click();
      document.body.click();
    JS

    expect(page).to have_no_css('.block_timerange')
  end
end
