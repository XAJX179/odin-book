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

  authenticate :user do
    root to: redirect("/posts"), as: :authenticated_root
    resources :users, only: %i[index] do
      resource :profile, only: %i[edit update show], controller: "users"
      resources :friends, only: %i[index show destroy]
      collection do
        get "/load_all" => "users#load_all", as: :load_all
      end
      member do
        get "/posts" => "posts#index_by_user", as: :posts_index_for
        get "/load_posts" => "posts#load_by_user", as: :load_posts_for
        get "/load_friends" => "friends#load_for_user", as: :load_friends_for
      end
    end

    resources :friend_requests, only: %i[index new create show destroy] do
      collection do
        get "/incoming" => "friend_requests#incoming", as: :incoming
        get "load_incoming" => "friend_requests#load_incoming",
            as: :load_incoming
        get "/outgoing" => "friend_requests#outgoing", as: :outgoing
        get "load_outgoing" => "friend_requests#load_outgoing",
            as: :load_outgoing
      end
    end

    resources :posts do
      resources :comments
      resources :likes, only: %i[index create destroy]
      collection do
        get "/load_all" => "posts#load_all", as: :load_all
        get "/feed" => "posts#feed", as: :feed
        get "/load_feed" => "posts#load_feed", as: :load_feed
      end
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
