require 'sidekiq/web'

Rails.application.routes.draw do
  apipie
  post 'link_info/index'

  resources :profile_images
  resources :profile_videos
  resources :sponsors , :only => :show
  resources :cards, only: [:new, :destroy, :create]

  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  authenticated do
    root to: 'boards#feed', as: :authenitcated_root
  end

  root to: 'pages#home'
  resources :comments

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end
  resources :jobs do
    collection do
      get :my_jobs
    end
    member do
      get :payment
      patch :subscription_renew
    end
  end
  mount CzardomModels::Engine, at: '/'
  mount Payola::Engine, at: '/payments'
  mount CzardomAdmin::Engine, at: '/admin'
  mount CzardomMap::Engine, at: '/map'
  mount CzardomMessages::Engine, at: '/messages'
  mount CzardomEvents::Engine, at: '/calendar'

  get '/update_group_user_list', to: 'groups#update_group_user_list', as: :update_group_user_list
  put "update_event_image/:event_image_id", to: 'users#update_event_image', as: :update_event_image
  delete "delete_event_image/:event_image_id", to: 'users#delete_event_image', as: :delete_event_image
  put "update_event_video/:event_video_id", to: 'users#update_event_video', as: :update_event_video
  delete "delete_event_video/:event_video_id", to: 'users#delete_event_video', as: :delete_event_video
  get '/board', to: 'boards#board'
  get '/board/following', to: 'boards#following', as: :board_following
  get '/board/new', to: 'boards#new', as: :new_board
  post '/board', to: 'boards#create'
  post '/board/fetch_facebook_comments', to: 'boards#fetch_facebook_comments'
  get '/board/new_post', to: 'boards#new_post', as: :new_post_board
  get 'board/articles/:id', to: "boards#root_article", as: :article_board

  mount Forem::Engine, at: '/board'

  get '/preregister', to: 'pages#home'

  get '/earlybird', to: 'pages#earlybird'
  get '/complete', to: 'pages#complete'
  get '/thankyou', to: 'pages#thankyou'
  get '/express', to: 'pages#express'

  get '/pages/:id', to: 'pages#show'

  get '/account(/:id)/clients', to: 'users#edit_clients', as: :edit_user_clients
  get '/account(/:id)/groups', to: 'users#edit_groups', as: :edit_user_groups
  get '/account(/:id)/password', to: 'users#edit_password', as: :edit_password_user
  get '/account(/:id)', to: 'users#edit', as: :edit_user
  get '/verify_url', to: 'users#verify_url', as: :verify_url

  scope 'user', controller: :users do
    match '/followed', action: 'followed', as: :user_followed, via: [:get, :post]
    match '/followers', action: 'followers', as: :user_followers, via: [:get, :post]
    get '/posts', action: 'posts', as: :user_posts
  end
  post 'payment', to: "users#payment", as: :user_payment

  match '/czars', to: 'users#all_czars', via: [:get, :post]
  get '/update_czar_list', to: 'users#update_czar_list', as: :update_czar_list
  match '/confirm_account/:token', to: 'users#confirm_account', as: :confirm_account, via: [:get, :post]
  match '/make_payment/:token', to: 'users#make_payment', as: :make_payment, via: [:get, :post]
  match '/subscriptions', to: 'users#subscriptions', as: :subscriptions, via: [:get, :post]

  post 'billing', to: 'users#billing', as: :billing
  get 'my_invoice', to: 'users#my_invoice', as: :invoice


  resources :tips, only: [:index]
  resources :special_offers, only: [:index]
  resources :notifications, only: [:index]
  resources :likes, only: [:create]

  resources :orders, only: [:new, :create]
  resources :users, only: [:new, :create, :show] do
    collection do
      get :blurbs
    end
    # member do
    #   get :confirm_account
    # end
  end
  resources :groups, only: [:index, :show, :edit, :update]

  namespace :onboarding do
    resources :groups, only: [:index, :show] do
      member { post :join; post :leave }
    end

    resources :clients, only: [:index]
  end

  get '/states_for_country', to: 'pages#states_for_country'

  get '/:id/image', to: 'users#image', as: :user_image
  #get '/:id', to: 'users#show', as: :user
  patch '/:id', to: 'users#update', as: :update_user

  match '/hooks/fb_created_callback'  => "hooks#fb_created_callback",via: [:get, :post]

  post 'users/follow/:user_id' => "users#follow", as: :user_follow
  post ':id/recommend' => "users#recommend", as: :user_recommend
  patch 'users/:id', to: 'users#update'
  namespace :api do
    namespace :v1 do
      resources :notifications, only: [:index, :show] do
        collection do
          get :all_notifications
        end
      end
      devise_scope :user do
        post 'sessions' => 'sessions#create', :as => :login
        delete 'sessions' => 'sessions#destroy', :as => 'logout'
        post 'registrations' => 'registrations#create', :as => 'register'
        put 'registrations' => 'registrations#update', :as => 'update'
        get 'get_all_focus_areas' => 'registrations#get_all_focus_areas', :as => 'get_all_focus_areas'
        get 'get_all_core_skills' => 'registrations#get_all_core_skills', :as => 'get_all_core_skills'
      end
      resources :reset_passwords, only: [:index, :create]
      resources :jobs do
        collection do
          get :my_jobs
        end
      end
      resources :profiles, only: [:show] do
        collection do
          get :personal_details
          get :expertise
          # get :additional_info
          put 'update_expertise'
        end
      end
      post 'board_group' => 'profiles#board_group', :as => 'board_group'
      post 'users_by_name' => 'profiles#users_by_name', :as => 'users_by_name'
      # get 'board_group/:group_id' => 'profiles#board_group', :as => 'board_group'
      get 'main_board' => 'profiles#main_board', :as => 'main_board'
      get 'friend_profile/:friend_id' => 'profiles#friend_profile', :as => 'friend_profile'

      resources :events, only: [:index, :create]
      post 'filetered_events' => 'events#filetered_events', :as => 'filetered_events'

      resources :conversations, only: [:index,:create,:show]
      get 'inbox' => 'conversations#inbox', :as => 'inbox'
      get 'get_last_conversation' => 'conversations#get_last_conversation', :as => 'get_last_conversation'
      post 'reply' => 'conversations#reply', :as => 'reply'
      get 'trash/:conversation_id' => 'conversations#trash', :as => 'trash'
      get 'untrash/:conversation_id' => 'conversations#untrash', :as => 'untrash'
      get 'sent' => 'conversations#sent', :as => 'sent'

      resources :followings, only: [:index]
      get 'near_by_peoples' => 'followings#near_by_peoples', :as => 'near_by_peoples'
      get 'followed' => 'followings#followed', :as => 'followed'

      resources :api_posts
      get 'get_comments/:post_id' => 'api_posts#get_comments', :as => 'get_comments'
      post 'post_rply' => 'api_posts#post_rply', :as => 'post_rply'
      get 'subscribe/:topic_id' => 'api_posts#subscribe', :as => 'subscribe'
      get 'unsubscribe/:topic_id' => 'api_posts#unsubscribe', :as => 'unsubscribe'
      get 'follow/:user_id' => 'api_posts#follow', :as => 'follow'
      get 'get_topic/:topic_id' => 'api_posts#get_topic', :as => 'get_topic'

      resources :groups, only: [:index] do
        collection do
          post 'group_users'
        end
      end
      post 'update_groups' => 'groups#update_groups', :as => 'update_groups'
      post 'add_groups' => 'groups#add_groups', :as => 'add_groups'
      get 'all_groups' => 'groups#all_groups', :as => 'all_groups'

      namespace :admin do
        resources :tips
      end
    end
  end


end
Forem::Engine.routes.draw do
  apipie
  resources :sponsors , :only => :show
end
