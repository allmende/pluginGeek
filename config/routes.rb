Knight::Application.routes.draw do

  # Oauth
  get 'logout' => 'sessions#destroy', as: :logout
  get 'login' => 'sessions#login', as: :login

  match 'oauth/callback'  => 'oauths#callback'
  match 'oauth/:provider' => 'oauths#oauth', as: :auth_at_provider

  # Categories
  resources :categories, only: [:index, :show, :edit, :update]
  get ':language' => 'categories#index', as: :language, constraints: { language: /ruby|js|design/i }

  # Repos and Owners
  #   Note: Routes for generating url differ from routes reading url, some duplication here
  #   Cause: FriendlyId uses /repos/:id to generate route when using link_to
  #            while matching incoming requests is being done through seperate routes (as friendly_id contains slashes)
  resources :repos, only: [:index, :show, :edit] do
    collection do
      # Owner Routes
      # get ':owner' => 'users#show'
      # get ':owner/new' => 'users#new'
      # get ':owner/create' => 'users#create'
      # post ':owner/create' => 'users#create'

      # Repo Routes
      constraints name: /[^\/]+(?=\.html\z)|[^\/]+/ do
        get ':owner/:name/edit' => 'repos#edit'
        get ':owner/:name/create' => 'repos#create'
        get ':owner/:name(/*leftover)' => 'repos#show'
        put ':owner/:name' => 'repos#update'
        delete ':owner/:name' => 'repos#destroy'
      end

    end
  end

  # Root
  root to: 'categories#index'

  # For when to implement json response for repos#show
  # Constraints: name can be anything but cannot end on .html (and .json):constraints => { :name => /[^\/]+(?=\.html\z|\.json\z)|[^\/]+/ }

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

  # See how all your routes lay out with "rake routes"
end
