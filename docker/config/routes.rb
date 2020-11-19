require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  # ---------------
  # Health check and smoke test routes
  # ---------------
  get 'healthz', to: 'healthcheck#index', as: 'health_check'
  get 'statusz', to: 'healthcheck#show', as: 'status_check'

  # ---------------
  # Auth routes
  # ---------------
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/:provider', to: 'sessions#new'
  get 'auth/failure', to: redirect('/') # TODO: fix this to redirect to the web UI

  # ---------------
  # Resource routes
  # ---------------
  namespace :api do
    resources :sessions, only: %i[create index show destroy]
    resources :organizations
    resources :campaigns do
      resources :results, only: %i[index], to: 'campaign_results#index'
    end
    resources :profiles, only: %i[index show]
    resources :controls, only: %i[index show]
    resources :sources, only: %i[index show update]
    resources :jobs, only: %i[index]
    resources :users
  end
end
