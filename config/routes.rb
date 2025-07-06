Rails.application.routes.draw do
  devise_for :users
  resources :incidents
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"


  post 'slack/flag', to: 'slack#flag'

  root to: redirect("/incidents")
  
  # Slack Bot
  get '/slack/install', to: 'slack_auth#install_bot'
  get '/slack/oauth/callback', to: 'slack_auth#bot_callback'

  # Slack User Auth
  get '/auth/slack', to: 'slack_auth#start_user_auth', as: :slack_user_auth_start
  get '/auth/slack/callback', to: 'slack_auth#user_callback'

end
