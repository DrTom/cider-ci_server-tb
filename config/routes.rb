CiderCI::Application.routes.draw do

  namespace :executors_api_v1 do

    resources :trials do
      member do
        put 'attachments/*path', action: 'put_attachment', format: false, as: :attachment
      end
    end

    resources :repositories , only: [] do
      member do
        get 'git', as: 'git_root'
        get 'git/*path', action: 'get_git_file', format: false
      end
    end

    resources :scripts, only: [:update]
  end


  get '/workspace/dashboard', controller: "workspace" , action: "dashboard"


  namespace 'workspace' do

    resource :account, only: [:edit,:update] do
      post :email_addresses, to: "accounts#add_email_address"
      delete '/email_address/:email_address', email_address: /[^\/]+/, to: "accounts#delete_email_address", as: 'delete_email_address'
      post '/email_address/:email_address/as_primary', email_address: /[^\/]+/, to: "accounts#as_primary_email_address", as: 'primary_email_address'
    end

    resource :session, only: [:edit,:update]

    resources :tags, only: [:index]


    get 'branch_heads' #, controller: "workspace" 

    resources :branches do
      collection do
        get 'names'
      end
    end

    # resources :branch_heads, only: [:index]

    resources :trials do
      member do
        get 'attachments/*path', action: 'get_attachment', format: false, as: :attachment
        post 'set_failed'
      end
    end

    resources :branch_update_triggers
    resources :commits
    resources :executions do
      member do
        post :add_tags
        get :tasks
        post :retry_failed
      end
    end
    resources :executors

    resources :repositories do
      resources :branches
      member do
        get 'git', as: 'git_root'
        get 'git/*path', action: 'get_git_file', format: false
      end
      collection do
        get 'names'
      end
    end

    resources :tasks do
      member do
        post 'retry'
      end
    end

  end

  namespace 'admin' do
    resource :timeout_settings
    resources :branch_update_triggers
    resources :definitions
    resources :users do
      member do
        #resources :email_addreses
        get '/email_addresses', action: 'email_addressses' 
        post '/email_addresses', action: 'add_email_address' 
        put '/email_address/:email_address', email_address: /[^\/]+/, action: :put_email_address, as: :email_address
        post '/email_address/:email_address/as_primary', email_address: /[^\/]+/, action: :as_primary_email_address, as: :primary_email_address
        delete '/email_address/:email_address', email_address: /[^\/]+/, action: :delete_email_address, as: :delete_email_address
        #delete '/email_address/:email_address', email_address: /[^\/]+/, action: 'delete_email_address', as: :email_address
      end
    end
    resources :executors do
      member do
        post 'ping'
      end
    end
    resources :repositories do
      post 're_initialize_git' 
      post 'update_git'
    end
    get 'env'
    post 'dispatch_trials'
  end

  resource :public, only: [:show], controller: "public"

  namespace 'public' do
    post 'sign_in'
    post 'sign_out'
  end

  namespace 'perf' do
    root controller: "perf", action: "root"
  end

  get /.*/, controller: "application", action: "redirect"


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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
