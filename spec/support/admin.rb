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
