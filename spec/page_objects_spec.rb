require 'spec_helper'

# The page objects need active_admin_page_objects 2.x, which needs Active Admin 4.
if ActiveAdminDateRangePreset.aa_v4?
  require 'active_admin_date_range_preset/page_objects'

  describe 'page objects for the range menu', type: :feature, js: true do

    WEDNESDAY_NOON_PO = '2026-09-30T12:00:00Z'.freeze

    let(:posts_page) do
      Class.new(ActiveAdminPageObjects::Page) do
        set_url '/admin/posts'
        section :filters, ActiveAdminPageObjects::Filters
      end.new
    end
    let(:filter) { posts_page.filters.filter(:created_at) }

    before do
      add_post_resource
      freeze_browser_time(WEDNESDAY_NOON_PO)
      posts_page.load
    end

    it 'chooses a built-in preset and returns the range it shows' do
      expect(filter.choose_preset('Today')).to eq(%w[2026-09-30 2026-10-01])
      expect(filter.range).to eq(%w[2026-09-30 2026-10-01])
      expect(filter.choose_preset('this week')).to eq(%w[2026-09-28 2026-10-05])
    end

    it 'chooses a preset given to add_range' do
      page.execute_script(<<~JS)
        ActiveAdminDateRangePreset.init('#q_created_at_input', {
          add_range: [{ title: 'Last 7 days', start: new Date(2026, 8, 24), end: new Date(2026, 9, 1) }]
        });
      JS

      expect(filter.choose_preset('Last 7 days')).to eq(%w[2026-09-24 2026-10-01])
    end

    it 'names the presets on offer when there is none by that title' do
      expect { filter.choose_preset('Last decade') }.to raise_error(Capybara::ElementNotFound, /offers \["Today", "Yesterday"/)
    end
  end
end
