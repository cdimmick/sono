Rails.application.routes.draw do
  resources :facilities do
    member do
      resources :events
      resources :users
      # , except: [:show]
    end
  end

  devise_for :users

  get 'home', to: 'pages#home', as: 'home'

  root to: 'pages#home'
end
