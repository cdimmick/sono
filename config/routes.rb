Rails.application.routes.draw do
  get 'router', to: 'pages#router', as: 'router'

  root to: 'pages#router'

  resources :facilities

  resources :events do
    member do
      post 'invite'
      get 'download'
    end
  end

  devise_for :users, path: 'u', controllers: {sessions: 'custom_sessions'}

  resources :users do
    member do
      delete 'deactivate'
      get 'sign_ups/new', to: 'sign_ups#new'
      post 'sign_ups', to: 'sign_ups#create'
    end

    collection do
      get 'admins'
    end
  end

  resources :charges, only: [:create, :index, :destroy]
end
