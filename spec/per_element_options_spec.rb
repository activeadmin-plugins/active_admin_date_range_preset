require 'spec_helper'

describe 'two preset pairs on one form', type: :feature, js: true do

  let(:today) { Time.now.utc.to_date }

  before { add_post_resource_with_two_pairs }
  before { visit '/admin/posts/new' }

  def pick_today_in(wrapper_id)
    page.find("##{wrapper_id} a.btn_timerange").click
    page.find('.block_timerange .btn_today').click
  end

  def value_of(wrapper_id)
    page.find("##{wrapper_id}").find('input[type="text"]').value
  end

  it 'keeps the plain pair on dates' do
    pick_today_in('post_published_at_input')

    expect(value_of('post_published_at_input')).to eq(today.strftime('%Y-%m-%d'))
  end

  it 'keeps the data-show-time pair on datetimes' do
    pick_today_in('post_created_at_input')

    expect(value_of('post_created_at_input')).to eq(today.strftime('%Y-%m-%d 00:00:00'))
  end
end
