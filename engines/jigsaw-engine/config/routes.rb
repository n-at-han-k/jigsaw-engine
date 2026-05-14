Jigsaw::Engine.routes.draw do
  root "dashboard#index"

  resources :slots, only: [:index, :edit, :update] do
    member do
      get :data_source
      get :render_source
    end
  end
  resources :pages, only: [:index, :new, :create, :edit, :update, :destroy]
end
