Rails.application.routes.draw do
  authenticated :user, -> user { user.server_admin? } do
    match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]
  end

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks'
  }

  namespace :admin do
    resources :users do
      patch 'unlock' => 'users#unlock', on: :member
    end
    draw 'admin/administration'
    draw 'admin/communication'
    draw 'admin/education'
    draw 'admin/research'
    draw 'admin/university'
    root to: 'dashboard#index'
  end

  namespace :server do
    resources :universities
    resources :languages
    root to: 'dashboard#index'
  end

  get '/media/:signed_id/:filename_with_transformations' => 'media#show', as: :medium

  root to: 'admin/dashboard#index'
end
