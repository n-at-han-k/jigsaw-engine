Jigsaw::Engine.routes.draw do
  root "dashboard#index"

  resources :page_modules, only: [:index, :edit, :update] do
    member do
      get :data_source
      get :render_source
    end
  end
  resources :layouts
  resources :custom_pages, only: [:index, :edit, :update]

  get "*path", to: "custom_pages#show",
      constraints: ->(req) {
        engine_path = req.path.sub(%r{\A/jigsaw}, "").delete_prefix("/")
        Jigsaw::CustomPage.exists?(path: engine_path)
      }
end
