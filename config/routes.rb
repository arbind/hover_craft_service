require 'sidekiq/web'
  HoverCraftService::Application.routes.draw do

  class AuthConstraint
    def self.admin?(request)
      AuthorizedUsers.service.authorized? request.session[:current_user]
    end
  end

  constraints lambda {|request| AuthConstraint.admin?(request) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/ping' => 'root#ping', as: :ping

  root 'dashboard#show', as: :dashboard
  get '/settings' => 'dashboard#settings', as: :settings

  get 'auth/login' => 'auth#new', as: :login
  get 'auth/logout' => 'auth#logout', as: :logout

  get 'auth/:provider/callback' => 'auth#oauth_sign_in'
  get 'auth/:provider/failure' => 'auth#oauth_failure'

  resources :tweet_streamers, except: [:update] do
    get 'populate_from_streamer'
    get 'populate_from_streamers', on: :collection
  end

  resources :hover_crafts do
    get 'populate_hover_crafts', on: :collection
  end

  resources :sidekiq_admin, only: [:index] do
    get 'clear_scheduled_jobs', on: :collection
    get 'clear_stats', on: :collection
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
