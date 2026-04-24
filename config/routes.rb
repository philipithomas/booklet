Rails.application.routes.draw do
  get "/health", to: proc { [ 200, {}, [ "bklt" ] ] }

  if Rails.configuration.multiuser_mode
    # Domain redirects (legacy domains to current)
    domain_redirects = {
      "oimc.bklt.app" => "oimc.booklet.group",
      "bklt.app" => "app.booklet.group",
      "new.booklet.community" => "new.booklet.group",
      "hq.booklet.community" => "hq.booklet.group",
      "demo.booklet.community" => "demo.booklet.group",
      "docs.booklet.community" => "docs.booklet.group",
      "booklet.community" => "booklet.group",
      "www.booklet.community" => "www.booklet.group",
      "booklet.work" => "booklet.group",
      "www.booklet.work" => "booklet.group",
      "members.frctnl.xyz" => "www.frctnl.xyz",
      "frctnl.xyz" => "www.frctnl.xyz",
      "aidev.forum" => "www.aidev.forum"
    }.freeze

    domain_redirects.each do |source, target|
      constraints(host: source) do
        root to: redirect("https://#{target}"), as: "redirect_#{source.tr(".", "_")}"
        match "*path", via: :all, to: redirect { |params, request|
          "https://#{target}#{request.fullpath}"
        }
      end
    end

    # New communities
    get "/" => "setup#new", :constraints => { host: Rails.configuration.signup_host }, :as => :new_community
    post "/" => "setup#create", :constraints => { host: Rails.configuration.signup_host }, :as => :communities
    get "/cancel/:community_id" => "setup#cancel", :constraints => { host: Rails.configuration.signup_host }, :as => :cancel_community
    get "/welcome/:community_id" => "setup#welcome", :constraints => { host: Rails.configuration.signup_host }, :as => :welcome_community

    # Development redirect + homepage
    get "/" => redirect("http://#{Rails.configuration.marketing_host}:3000"), :constraints => { host: "localhost" }
    get "/" => "marketing#app_home", :constraints => { host: Rails.configuration.base_host }, :as => :marketing_root

    # Marketing page
    get "/" => "marketing#home", :constraints => { host: Rails.configuration.marketing_host.to_s }

    resources :switch, param: :slug

    constraints(host: Rails.configuration.index_host) do
      root to: "index#index", as: :index
      post "/", to: "index#create"
      delete "/", to: "index#destroy"
    end

    # Editor
    constraints(host: Rails.configuration.editor_host) do
      devise_for :editors, controllers: {
        sessions: "editor/sessions",
        registrations: "editor/registrations",
        passwords: "editor/passwords",
        confirmations: "editor/confirmations"
      }
      scope module: :editor do
        get "/", to: "home#index", as: :editor_root
        get "/growth", to: "growth_chart#index", as: :growth_chart
        get "/growth/data", to: "growth_chart#data", as: :growth_chart_data
        resources :editor_communities, param: :slug, controller: "communities", path: "c"
        resources :editor_posts, param: :id, controller: "posts", path: "p"
        resources :editor_replies, param: :id, controller: "replies", path: "r"
        resources :editor_members, param: :id, controller: "members", path: "m"
      end

      authenticate :editor, ->(editor) { editor.present? } do
        mount PgHero::Engine, at: "db"
        mount MissionControl::Jobs::Engine, at: "/jobs"
        mount Blazer::Engine, at: "analytics"
      end
    end
  end # multiuser_mode

  get "/robots.txt" => "robots#show", :as => :robots

  mount Ahoy::Engine => "/labyrinth"

  constraints(host: Rails.configuration.api_host) do
    scope module: :api do
      mount Rswag::Ui::Engine => "/"
      mount Rswag::Api::Engine => "/api-docs"
      resources :members, param: :id, constraints: { id: /[^\/]+/ }
    end
  end

  # Communities

  get "/og/:updated_at", as: :community_og_image, to: "communities#og_image"

  # Render dynamic PWA files from app/views/pwa/*

  scope module: :communities do
    get "service_worker" => "pwa#service_worker", :as => :pwa_service_worker
    get "manifest" => "pwa#manifest", :as => :pwa_manifest
    get "email_logo" => "email_logo#show", :as => :email_logo

    get "members/invitations", to: redirect("members/all")
    get "members/all", to: "members#index_all", as: :all_members

    resources :members, param: :slug do
      get "contact", to: "members/contact#new"
      post "contact", to: "members/contact#create"
    end
    resources :notification_preferences, path: "notifications", param: :token
    post "/notifications/:token", to: "notification_preferences#list_unsubscribe"

    resources :search, path: "search", param: :query
    resources :mentions, only: [ :index ]
    resources :push_subscriptions
    resources :verifications

    root to: "posts#index", as: :posts

    get "posts/recommended", to: "posts#recommended", as: :recommended_posts
    resources :posts, param: :slug do
      post "follow", to: "posts#follow"
      delete "follow", to: "posts#unfollow"
      get "og/:updated_at", as: :og_image, to: "posts#og_image"

      resources :replies, param: :slug
      resources :views, only: [ :index ], path: "views", controller: "post_views"
      resources :draft
    end

    resources :follows, only: [], param: :signed_id do
      get :unsubscribe
      post :confirm_unsubscribe
    end

    # Redirect /settings to /settings/notifications
    get "/settings", to: redirect("/settings/notifications")

    namespace :settings do
      resource :notifications, only: [ :show, :update ]
      resource :branding, only: [ :show, :update ], controller: "branding"
      resource :pinned_post, only: [ :update ], controller: "pinned_post"
      resource :hosting, only: [ :show, :update, :destroy ], controller: "hosting"
      resource :subscription, only: [ :show, :update ], controller: "subscription"
      resource :billing, only: [ :show, :update ], controller: "billing"
      resource :newsletter, only: [ :show, :update ], controller: "newsletter"
      resource :moderation, only: [ :show, :update ], controller: "moderation"
      resource :confirmation, only: [ :show ], controller: "confirmation"
      resources :custom_domain, controller: "custom_domain"
      get "defaults", to: redirect("/settings/newsletter")
      resources :api_keys, controller: "api_keys"
      resources :features, controller: "features", only: [ :index ]
      resources :feature, controller: "feature", only: [ :show, :update ], path: "features"
      resources :integrations, controller: "integrations", only: [ :index ]
    end
  end

  devise_for :members, controllers: {
    sessions: "members/sessions",
    registrations: "members/registrations",
    confirmations: "members/confirmations",
    invitations: "members/invitations"
  }, path: "", path_names: {
    sign_in: "sign-in",
    sign_out: "sign-out",
    sign_up: "sign-up"
  }
  devise_scope :member do
    # redirect /passwordless to sessions
    get "/passwordless", to: redirect("/sign-in")
    get "/passwordless/:id", to: "members/passwordless_sessions#show", as: :passwordless_signin
  end

  get "/confirmation-pending" => "communities#confirmation_pending", :as => :members_registrations_confirmation_pending

  direct :cdn_proxy do |model, options|
    expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }

    if model.respond_to?(:signed_id)
      route_for(
        :rails_service_blob_proxy,
        model.signed_id(expires_in: expires_in),
        model.filename,
        options.merge(host: Rails.configuration.cdn_host)
      )
    else
      signed_blob_id = model.blob.signed_id(expires_in: expires_in)
      variation_key = model.variation.key
      filename = model.blob.filename

      route_for(
        :rails_blob_representation_proxy,
        signed_blob_id,
        variation_key,
        filename,
        options.merge(host: Rails.configuration.cdn_host)
      )
    end
  end
end
