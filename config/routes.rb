Rails.application.routes.draw do
  get 'home/index'
#   get 'errors/not_found'
#   get 'errors/internal_server_error'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "home#index"

  delete 'members/destroy' => "members#destroy"
  post 'members/edit' => "members#edit"

  resources :projects do
    resources :members
  end

  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  
end
