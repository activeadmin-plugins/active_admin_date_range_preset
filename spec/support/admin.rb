def add_post_resource
  ActiveAdmin.register Post do
    config.filters = true

    permit_params :title, :body, :published_at

    filter :created_at, as: :date_range

    form do |f|
      f.inputs do
        f.input :title
        f.input :published_at, as: :string,
                wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
        f.input :body, as: :string
      end
      f.actions
    end
  end

  Rails.application.reload_routes!
end

# Two pairs on one form, only the second asking for time. The auto-init
# matches both in a single plugin call, which is what makes one pair's
# options visible to the other.
def add_post_resource_with_two_pairs
  ActiveAdmin.register Post do
    config.filters = true

    permit_params :title, :body, :published_at

    form do |f|
      f.inputs do
        f.input :published_at, as: :string,
                wrapper_html: { class: 'datetime_preset_pair' }
        f.input :body, as: :string
        f.input :created_at, as: :string,
                wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }
        f.input :updated_at, as: :string
      end
      f.actions
    end
  end

  Rails.application.reload_routes!
end
