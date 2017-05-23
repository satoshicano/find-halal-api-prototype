Rails.application.routes.draw do
  resources :words
  root 'pictures#new'
  resources :pictures
  post 'check_halal', to: 'pictures#create_from_android'
end
