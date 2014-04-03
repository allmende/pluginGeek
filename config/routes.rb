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

  # Categories list / Platforms
  get '/', to: 'categories#index', as: :all_platforms

  PLATFORM_SLUGS = %w(ruby javascript js html-css)
  get '/:platform_slug', to: 'categories#index', constraints: { platform_slug: /(#{PLATFORM_SLUGS.join('|')})/i }, as: :platform

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

  # Static pages
  get ':id', to: 'high_voltage/pages#show', as: :static

  # Root route
  root to: 'categories#index'
end
