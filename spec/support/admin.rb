def add_post_resource
  ActiveAdmin.register Post do
    config.filters = true

    permit_params :title, :body, :published_at

    filter :created_at, as: :date_range
    # Both inputs in one .datetime_preset_pair wrapper, the markup
    # active_admin_datetimepicker's range filter renders. Auto-initialised.
    filter :published_at, as: :date_range, wrapper_html: { class: 'datetime_preset_pair' }

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
        # Not .datetime_preset_pair, so the auto-init leaves it alone and the
        # spec can drive it with explicit options.
        f.input :title, as: :string,
                wrapper_html: { class: 'manual_preset_pair', data: { show_time: 'false' } }
      end
      f.actions
    end
  end

  Rails.application.reload_routes!
end

# Native pickers: the plugin writes ISO values into them on any Active Admin.
def add_post_resource_with_native_pickers
  ActiveAdmin.register Post do
    config.filters = false

    permit_params :title, :body, :published_at, :created_at, :updated_at

    form do |f|
      f.inputs do
        f.input :published_at, as: :datetime_picker, wrapper_html: { class: 'datetime_preset_pair' }
        f.input :created_at, as: :datetime_picker
        f.input :updated_at, as: :date_picker, wrapper_html: { class: 'datetime_preset_pair' }
        f.input :title, as: :date_picker
      end
      f.actions
    end
  end

  Rails.application.reload_routes!
end
