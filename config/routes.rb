ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "efforts"

  # See how all your routes lay out with "rake routes"
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
# Non-CRUD
  # english_time
  map.full_time 'english_time/full_time', :controller => 'english_time', :action => 'full_time'
  
  # efforts
  map.select_effort_customer 'efforts/select_customer/:id', :controller => 'efforts', :action => 'select_customer'
  map.start_effort 'efforts/start_effort', :controller => 'efforts', :action => 'start_effort'
  map.finish_effort 'efforts/finish_effort', :controller => 'efforts', :action => 'finish_effort'
  map.check_unfinished_duration 'efforts/check_unfinished_duration', :controller => 'efforts', :action => 'check_unfinished_duration'
  map.cancel_unfinished_effort 'efforts/cancel_unfinished_effort', :controller => 'efforts', :action => 'cancel_unfinished_effort'
  map.set_day 'efforts/set_day', :controller => 'efforts', :action => 'set_day'
  map.set_month 'efforts/set_month', :controller => 'efforts', :action => 'set_month'
  map.breakdown 'efforts/breakdown', :controller => 'efforts', :action => 'breakdown'
  
  # overviews
  map.select_user_overview 'overviews/index', :controller => 'overviews', :action => 'select_user'
  
# RESTful resources
  map.resources :users
  map.resource :session
  map.resources :efforts
  map.resources :overviews
  
  # Nested resource for contracts
  map.resources :customers do |customer|
    customer.resources :contracts, :controller => 'customers/contracts',
                                   :name_prefix => 'customer_'
  end


  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
