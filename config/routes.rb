Tvshows::Application.routes.draw do
  #get "episodes/show"
  #get "seasons/show"
  #get "genres/show"
  #get "roles/index"
  #get "roles/show"
  #get "actors/index"
  #get "actors/show"
  resources :subscriptions
  match '/auth/:provider/callback' => "authentications#create"
  resources :authentications

  devise_for :users, :path_names => { :sign_up => "register",
                                      :sign_in => "login",
                                      :sign_out => "logout" },
             :controllers => { :registrations => 'registrations' } do
    get "users/cancel_omniauth", :to => "registrations#cancel_omniauth"
  end      

  get "shows/index"

  resources :actors, :only => [:show]
  
  resources :shows, :only => [:index, :show] do
    resources :actors, :only => [:show, :index], :controller => "roles"
    collection do
      post :search
      get :search
      get :my
      get :name
      get :popular
    end
    member do
      get 'add'  
      get 'subscribe'
      get 'unsubscribe'
      post 'comment'
      get 'get_poster'
    end
    match "/season/:season_number" => "seasons#show", :constraints => { :season_number => /\d+/ }, :as => "seasons"
    match "/:season_number/:episode_number" => "episodes#show", :constraints => { :season_number => /\d+/, :episode_number => /\d+/ }, :as => "season_episode"
  end
  scope "shows", :as => "shows" do
    resources :genres, :only => [:show]
  end
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
