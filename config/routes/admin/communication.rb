namespace :communication do
  get 'unsplash' => 'unsplash#index'
  resources :websites do
    member do
      scope '/:lang' do
        get :import
        post :import
        get :style
        get :analytics
      end
    end
    resources :pages, controller: 'websites/pages', path: '/:lang/pages' do
      collection do
        post :reorder
      end
      member do
        get :children
        get :static
        get :preview
        get "translate/:iso_code" => "websites/pages#translate", as: :translate
        post :duplicate
      end
    end
    resources :categories, controller: 'websites/categories', path: '/:lang/categories' do
      collection do
        post :reorder
      end
      member do
        get :children
        get :static
      end
    end
    resources :authors, controller: 'websites/authors', path: '/:lang/authors', only: [:index, :show]
    resources :posts, controller: 'websites/posts', path: '/:lang/posts' do
      collection do
        resources :curations, as: :post_curations, controller: 'websites/posts/curations', only: [:new, :create]
        post :publish
      end
      member do
        get :static
        get :preview
      end
    end
    resources :menus, controller: 'websites/menus', path: '/:lang/menus' do
      resources :items, controller: 'websites/menus/items', except: :index do
        collection do
          get :kind_switch
          post :reorder
        end
        member do
          get :children
        end
      end
    end
  end
  resources :blocks, controller: 'blocks', except: [:index] do
    collection do
      post :reorder
    end
    member do
      post :duplicate
    end
  end
  resources :extranets, controller: 'extranets'
  resources :alumni do
    collection do
      resources :imports, only: [:index, :show, :new, :create]
    end
  end
end
