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

  # show_time passed to the call is the documented way to turn time on for a
  # group of inputs. data-show-time="false" is then the only way for one of
  # them to opt out, and the attribute was write-only: the guard assigned
  # true and never false.
  it 'lets data-show-time="false" opt back out of a call that asked for time' do
    page.execute_script("$('.manual_preset_pair').date_range_ext_preset({ show_time: true });")

    pick_today_in('post_title_input')

    expect(value_of('post_title_input')).to eq((today + 1).strftime('%Y-%m-%d'))
  end
end
