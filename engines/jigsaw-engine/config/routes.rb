Jigsaw::Engine.routes.draw do
  root "dashboard#index"

  resources :layout_templates, only: [:index, :new, :create, :edit, :update, :destroy]

  resources :slot_templates do
    member do
      get :data_source
      get :render_source
    end
  end

  resources :slots, only: [:index, :edit, :update] do
    member do
      get :data_source
      get :render_source
      post :unlink_template
      post :link_template
    end
  end

  resources :pages, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      post :unlink_template
    end
  end
end
