require 'sidekiq/web'

module PPCConstraint
  extend self

  def matches?(request)
    !request.query_parameters["hotel"].blank?
  end
end

Hotels::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  constraints(:subdomain => /^cdn\b/) do
    root :to => redirect("http://www.hot5.com")
    match '/*path', :to => redirect {|params| "http://www.hot5.com/#{params[:path]}"}
  end


  match "/" => "search#index", :constraints => PPCConstraint

  root :to => 'app#index'

  
  match "/404", :to => "app#not_found"
  match "/500", :to => "app#not_found"

  mount Sidekiq::Web, at: "/sidekiq"
  mount Soulmate::Server, :at => '/sm'

  get '/offer/:provider',           to: 'offer#index'
  match '/geolocate_error',         to: 'analytics#geolocate_error', constraints: { :subdomain => /^analytics\b/ }
  get '/locations',                 to: 'search#locations'
  get '/reports/:action',           to: 'reports#:action'
  get '/map/:id',                   to: 'map#index'
  
  resources :hotels, only: [:index, :show] do
    member do
      get '/rooms', to: 'hotels#rooms'
    end
  end

  get '/:id', to: 'search#index'





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
  # 

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
