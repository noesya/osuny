namespace :server do
  resources :universities
  resources :languages
  resources :websites do
    collection do
      post :clean_and_rebuild_all_websites
    end
    member do
      post :sync_theme_version
      post :update_theme
    end
  end
  resources :blocks, only: [:index, :show] do
    post :resave, on: :member
  end
  resources :emergency_messages do
    member do
      post :deliver
    end
  end
  root to: 'dashboard#index'
end
