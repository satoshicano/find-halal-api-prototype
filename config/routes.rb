Rails.application.routes.draw do
  resources :words
  root 'pictures#new'
  # resources :pictures, only: %i[new create]
  resources :pictures
  namespace :api do
    namespace :v1 do
      post 'check_halal' => 'images#check_halal'
    end
  end
end
