Rails.application.routes.draw do
  resources :power_supplies do
    get :reprocess, on: :collection
    delete :delete_common, on: :collection
    patch :set_favorite
  end
  # get '/power_supplies/reprocess', to: 'power_supplies#reprocess'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: "power_supplies#index"
end
