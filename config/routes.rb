Plugingeek::Application.routes.draw do
  # User authentication
  devise_for :users,
    path_names: {sign_in: 'login', sign_out: 'logout'},
    controllers: {omniauth_callbacks: 'omniauth'}

  devise_scope :user do
    get 'login',     to: 'devise/sessions#new',     as: :new_user_session
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # Shorthands
  get 'login', to: 'devise/sessions#new', as: :login
  delete 'logout', to: 'devise/sessions#destroy', as: :logout

  # Platforms
  resources :platforms, only: :show do
    resources :categories, only: :index
  end

  # Categories
  resources :categories, except: :index

  # Repos
  resources :repos, constraints: { id: %r{[^\/]+[\/][^\/]+} }, except: [:index, :new]

  # Links
  resources :links, except: :show

  # Services
  resources :services

  # Submissions
  get 'submit' => 'submissions#submit', as: :submit

  # Dynamic robots.txt
  get 'robots.:format' => 'robots#index'

  # Authorize blitz.io load testing
  get 'mu-a4ca81c6-8526fed8-0bc25966-0b2cc605' => 'application#authorize_blitz_io' # standalone
  get 'mu-943299b6-11bc48bc-a8df1760-5139a504' => 'application#authorize_blitz_io' # blitz.io heroku addon

  # Authorize loader.io load testing
  get 'loaderio-ca7d285a7cea4be8e79cecd78013aee6' => 'application#authorize_loader_io' # loader.io heroku addon

  # Static pages
  get ':id', to: 'high_voltage/pages#show', as: :static

  # Note: Make sure there's a platform with slug=ruby
  root to: 'platforms#show', id: Platform.default_slug
end
