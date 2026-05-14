Jigsaw::Engine.routes.draw do
  root "dashboard#index"

  resources :slots, only: [:index, :edit, :update] do
    member do
      get :data_source
      get :render_source
    end
  end
  resources :pages, only: [:index, :new, :create, :edit, :update, :destroy]

  # Dynamically register a GET route for each Page record.
  # The DB / table may not exist yet (initial setup, migrations not run);
  # rescue broadly so booting the app never fails.
  begin
    if ActiveRecord::Base.connection.data_source_exists?("jigsaw_pages")
      Jigsaw::Page.where.not(path: [nil, ""]).find_each do |page|
        get page.path, to: "pages#show", defaults: { path: page.path }, as: "page_#{page.id}_route"
      end
    end
  rescue StandardError => e
    Rails.logger.warn("[jigsaw] skipping dynamic page routes: #{e.class}: #{e.message}") if defined?(Rails.logger)
  end
end
