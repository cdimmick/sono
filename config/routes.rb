Rails.application.routes.draw do
  resources :facilities do
    member do
      resources :events
    end
  end

  devise_for :users, path: 'u'
  resources :users, except: [:show]

  get 'home', to: 'pages#home', as: 'home'

  root to: 'pages#home'
end
