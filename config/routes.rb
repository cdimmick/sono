Rails.application.routes.draw do
  resources :events
  resources :facilities
  devise_for :users

  get 'home', to: 'pages#home', as: 'home'

  root to: 'pages#home'
end
