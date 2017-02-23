Rails.application.routes.draw do
  get 'api_test' => "api_test#index"

  resources :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  mount API => '/'
  # You can have the root of your site routed with "root"
  root 'users#index'
end
