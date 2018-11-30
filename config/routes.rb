Rails.application.routes.draw do
  get 'home', to: 'pages#home', as: 'home'

  root to: 'pages#home'

  resources :facilities

  resources :events

  devise_for :users, path: 'u'

  resources :users, except: [:show]

  resources :charges, only: [:create]
end
