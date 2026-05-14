Jigsaw::Engine.routes.draw do
  root "dashboard#index"

  resources :slots, only: [:index, :edit, :update] do
    member do
      get :data_source
      get :render_source
    end
  end
  resources :layouts
  resources :pages, only: [:index, :edit, :update]

  get "*path", to: "pages#show",
      constraints: ->(req) {
        engine_path = req.path.sub(%r{\A/jigsaw}, "").delete_prefix("/")
        Jigsaw::Page.exists?(path: engine_path)
      }
end
