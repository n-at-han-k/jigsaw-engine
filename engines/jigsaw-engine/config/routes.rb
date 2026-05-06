Jigsaw::Engine.routes.draw do
  root "dashboard#index"

  resources :data_functions
  resources :render_functions
  resources :page_modules,     only: [:index, :edit]
  resources :layouts

  get "*path", to: "custom_pages#show",
      constraints: ->(req) {
        engine_path = req.path.sub(%r{\A/jigsaw}, "").delete_prefix("/")
        Jigsaw::CustomPage.exists?(path: engine_path)
      }
end
