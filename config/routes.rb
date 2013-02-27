SalonFryz::Application.routes.draw do
  resources :roles

  resources :visits do
    get "/register" => "visits#register"
  end
  
  post "/visits/new" => "visits#new"
  get "/choose_duration" => "visits#choose_duration", :as => :choose_duration
  get "/quick_choice" => "visits#choose_duration", :as => :choose_duration
  post "/quick_choice" => "visits#quick_choice", :as => :quick_choice
  post "/visits/:id" => "visits#confirm"
  get "/all_hairdressers_visit" => "visits#hairdresser_visits", :as => :hairdresser_visits
  get "/all_clients_visit" => "visits#client_visits", :as => :client_visits
  
  devise_for :users do
    get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end
  
  resources :users do
    get "/schedule" => "users#manage_schedule", :as => :schedule
    post "/schedule" => "users#manage_schedule", :as => :schedule
    get "/confirm" => "users#confirm_user", :as => :confirm
  end
  
  post "/user/new" => "users#create", :as => :new_hairdresser
  get "/list_to_confirm" => "users#list_to_confirm"
  get "/report" => "users#report"

  get "static_pages/home"
  
  root :to => "static_pages#home"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
