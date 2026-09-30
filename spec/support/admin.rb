def add_post_resource
  ActiveAdmin.register Post do
    config.filters = true

    permit_params :title, :body, :published_at

    filter :created_at, as: :date_range
  end

  Rails.application.reload_routes!
end
