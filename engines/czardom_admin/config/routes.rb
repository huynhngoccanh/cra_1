CzardomAdmin::Engine.routes.draw do
  root to: 'pages#dashboard'
  resources :sales, :products, :conversations, :regions, :tips, :special_offers

  resources :jobs
  resources :users do
    member do
      post :impersonate
      # get :user_status
    end
  end

  get 'users/user_status/:id', to: "users#user_status"
  get 'users/create_plan/:id', to: 'users#create_plan', as: :create_plan
  get 'users/plans/:id', to: 'users#plans', as: :plans

  resources :events, except: :create do
    collection do
      post :index
    end
  end

  resources :slides do
    collection do
      post :update_position
    end
  end

  resources :root_articles
  
  resources :sponsor_logos
  
  resources :groups do
    member { post :create_board }
  end
  
  resources :subscription_plans
  
  post 'groups/:id/sponsors', to: "sponsor_logos#add_group_sponsor", as: :add_sponsor_to_group
end
