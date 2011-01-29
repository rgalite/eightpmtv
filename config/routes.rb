Tvshows::Application.routes.draw do
  match '/auth/:provider/callback' => "authentications#create"
  resources :authentications, :only => [:create, :destroy]

  devise_for :users, :path_names => { :sign_up => "register",
                                      :sign_in => "login",
                                      :sign_out => "logout" },
             :controllers => { :registrations => 'registrations', :sessions => 'sessions' } do
    get "users/cancel_omniauth", :to => "registrations#cancel_omniauth", :as => "cancel_omniauth"

    root :to => "sessions#index"
  end      

  resources :actors, :only => [:show]
  resources :seasons, :only => [:comment] do
    member do
      post :comment
      get  :get_poster
    end
  end
  resources :episodes, :only => [] do
    member do
      post :comment
      get  :get_poster
    end
  end
  resources :shows, :only => [:index, :show] do
    resources :actors, :only => [:show, :index], :controller => "roles"
    collection do
      post :search
      get :search
      get :name
      get :popular
    end
    member do
      get :add  
      get :follow
      get :unfollow
      post :comment
      get :get_poster
      get :get_seasons
    end
    match "/season/:season_number" => "seasons#show", :constraints => { :season_number => /\d+/ }, :as => "season"
    match "/:season_number/:episode_number" => "episodes#show", :constraints => { :season_number => /\d+/, :episode_number => /\d+/ }, :as => "season_episode"
  end
  scope "shows", :as => "shows" do
    resources :genres, :only => [:show]
  end
  resources :users, :only => [:show, :index] do
    collection do
      get :name
    end
    member do
      get :follow
      get :unfollow
      get :followers
      get :following
      get :block
      get :unblock
    end
  end
  resources :comments, :only => [] do
    member do
      get :like
      get :unlike
      get :dislike
      get :undislike
    end
  end
  
  namespace "my" do
    resources :shows, :only => [:index, :show]
  end
  
  match '/robots.txt', :controller => :application, :action => :robots
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "sessions#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
