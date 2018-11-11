Rails.application.routes.draw do
  resources :events
  resources :facilities
  devise_for :users

  get 'home', to: 'pages#home', as: 'home'
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
