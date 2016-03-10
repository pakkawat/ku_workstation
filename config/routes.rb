Rails.application.routes.draw do
  resources :chef_attributes

  #match 'program/:program_id/chef_resource/:chef_resource_id/chef_property/:id', to: 'chef_properties#edit', as: 'edit_chef_property', :via => "get"
  resources :chef_properties

  resources :program_chefs

  match 'program/:program_id/chef_resource/:id', to: 'chef_resources#edit', as: 'edit_program_chef_resource', :via => "get"
  match 'program/:program_id/chef_resource/:id', to: 'chef_resources#update', as: 'update_program_chef_resource', :via => "patch"
  resources :chef_resources

  get 'logs/system_log', to: 'logs#system_log'
  resources :logs, :only => [:index, :show]
  #get 'logs/system_log', to: 'logs#system_log'

  get 'command_jobs/index'

  #get 'program_files/index'
  #match '*page', to: 'pages#show', via: :get
  #get 'programs/index'

  #get 'sessions/new'

  #get 'welcome/index'
  root 'sessions#new'
  #resources :users
  resources :ku_users
  #match "/ku_users/:ku_user_id/user_programs", :to => "ku_users#user_programs", :via => "get"
  #match '/teacher', to: 'users#teacher', via: :get
  #match '/student', to: 'users#student', via: :get
  resources :subjects do
    resources :user_subjects
    resources :programs_subjects
  end
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  match "/subjects/:subject_id/user_subjects", :to => "user_subjects#destroy", :via => "delete"
  match "/subjects/:subject_id/programs_subjects", :to => "programs_subjects#destroy", :via => "delete"
  #match "programs/:program_id/*program_file", :to => "program_files#show", :via => "get"


  resources :programs do
    resources :program_chefs
    put :sort, on: :collection
  end
  get 'programs/:program_id/apply_change', to: 'programs#apply_change', via: :get
  get 'programs/:program_id/upload_cookbook', to: 'programs#upload_cookbook', via: :get # danger! if file name "upload_cookbook"
  match "programs/:program_id/*program_files", :to => "program_files#show", :via => "get", :constraints => { :program_files => /[^*]+/ }#fix dot in url and allows anything except *
  match "programs/:program_id/*program_files", :to => "program_files#save_file", :via => "patch", :constraints => { :program_files => /[^*]+/ }
  match "programs/:program_id/*program_files", :to => "program_files#new_file", :via => "post", :constraints => { :program_files => /[^*]+/ }
  match "programs/:program_id/*program_files", :to => "program_files#delete_file", :via => "delete", :constraints => { :program_files => /[^*]+/ }
  #match '/new_file', to: 'programs#new_file', via: :post
  #match '/delete_file', to: 'programs#delete_file', via: :post
  #match '/programs/view_file', to: 'programs#view_file', via: :post
  #match '/save_file', to: 'programs#save_file', via: :post
  #get 'subjects/:subject_id/program_apply', to: 'programs_subjects#program_apply', via: :get
  #get 'subjects/:subject_id/subject_apply', to: 'user_subjects#subject_apply', via: :get
  get 'subjects/:subject_id/apply_change', to: 'subjects#apply_change', via: :get
  resources :instances
  get "/command_jobs/refresh_part" => 'command_jobs#refresh_part', as: 'command_jobs/refresh_part'
  match "/command_jobs/:job_id", :to => "command_jobs#destroy", :via => "delete", as: :command_job
  #resources :command_jobs


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
