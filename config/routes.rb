# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             controllers: { omniauth_callbacks: "users/omniauth_callbacks" },
             path_names: { sign_in: "login", sign_out: "logout" }

  unauthenticated do
    as :user do
      root to: "devise/sessions#new"
    end
  end

  authenticated :user do
    root to: redirect("/posts"), as: :authenticated_root
    resources :users, only: %i[index] do
      resource :profile, only: %i[edit update show]
      resources :friend_requests, only: %i[index new create show destroy]
      get  "load_incoming_friend_requests" => "friend_requests#load_incoming_friend_requests",
           as: :load_incoming_friend_requests
      get  "load_outgoing_friend_requests" => "friend_requests#load_outgoing_friend_requests",
           as: :load_outgoing_friend_requests
      resources :friends, only: %i[index show destroy]
    end
  end

  resources :posts do
    resources :comments
    resources :likes, only: %i[index create destroy]
    collection do
      get "/user_feed_posts" => "posts#user_feed_index", as: :user_feed_index
      get "/load_user_feed_posts" => "posts#load_user_feed_posts", as: :load_user_feed
      get "/load_posts" => "posts#load_posts", as: :load
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
