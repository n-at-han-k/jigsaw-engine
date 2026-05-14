Rails.application.routes.draw do
  mount Jigsaw::Engine, at: "/jigsaw"

  root to: redirect("/jigsaw")

  Jigsaw.dynamic_page_routes(self)

  get "up" => "rails/health#show", as: :rails_health_check
end
