require 'spec_helper'

describe 'where the "Set range" link sits', type: :feature, js: true do

  before { add_post_resource }

  # [left, top, width] of the label and of the link inside it.
  def geometry_of(scope)
    page.evaluate_script(<<~JS)
      (function () {
        var wrap  = document.querySelector('#{scope}');
        var label = wrap.querySelector('label');
        var link  = wrap.querySelector('a.btn_timerange');
        var box   = function (e) {
          var b = e.getBoundingClientRect();
          return { left: Math.round(b.left), top: Math.round(b.top),
                   width: Math.round(b.width), bottom: Math.round(b.bottom) };
        };
        return { label: box(label), link: box(link) };
      })();
    JS
  end

  # Active Admin gives a form label a 240px column. Floating the link to the
  # right of that column parks it far from the inputs it drives, with nothing
  # between the two. The documented look -- and the one the README screenshots
  # show -- is the link on its own line directly under the label text.
  context 'in a form pair' do
    before { visit '/admin/posts/new' }

    let(:geometry) { geometry_of('.datetime_preset_pair') }

    it 'starts at the same left edge as the label' do
      expect(geometry['link']['left']).to be_within(2).of(geometry['label']['left'])
    end

    it 'sits on its own line below the label text' do
      expect(geometry['link']['top']).to be >= geometry['label']['top']
    end

    it 'is only as wide as its own text, so the underline does not span the column' do
      expect(geometry['link']['width']).to be < geometry['label']['width']
    end
  end

  # The sidebar is the other half of the same CSS rule. There the label and the
  # link share a narrow panel, right alignment is what the README shows, and
  # nothing here should change it.
  context 'in the sidebar filter' do
    before { visit '/admin/posts' }

    let(:geometry) { geometry_of('.filter_date_range') }

    it 'stays pinned to the right of the label' do
      label_right = geometry['label']['left'] + geometry['label']['width']
      link_right = geometry['link']['left'] + geometry['link']['width']

      expect(link_right).to be_within(10).of(label_right)
    end
  end
end
