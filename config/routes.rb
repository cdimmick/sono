Rails.application.routes.draw do
  get 'home', to: 'pages#home', as: 'home'

  root to: 'pages#home'

  resources :facilities

  resources :events

  devise_for :users, path: 'u'

  resources :users, except: [:show] do
    member do
      delete 'deactivate'
      get 'sign_ups/new', to: 'sign_ups#new'
      post 'sign_ups', to: 'sign_ups#create'
    end

    collection do
      get 'admins'
    end
  end

  resources :charges, only: [:create]
end
