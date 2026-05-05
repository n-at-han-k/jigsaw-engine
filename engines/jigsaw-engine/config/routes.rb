Jigsaw::Engine.routes.draw do
  resources :data_functions,   only: [:show, :update], defaults: { format: :js }
  resources :render_functions,  only: [:show, :update], defaults: { format: :js }
  resources :page_modules,     only: [:edit]
  resources :layouts

  get "*path", to: "custom_pages#show",
      constraints: ->(req) {
        engine_path = req.path.sub(%r{\A/jigsaw}, "").delete_prefix("/")
        Jigsaw::CustomPage.exists?(path: engine_path)
      }
end
