PostHub::Application.routes.draw do
  #unless Rails.application.config.consider_all_requests_local
   # match '*not_found', to: 'errors#error_404'
  #end
  require "subdomain"

  constraints(Subdomain) do
    get '/' => 'blog#showBlog'
    get '/v1' => "api#main"

    get '/p/:pageID' => "blog#showPage"
    get '/p/:pageID/destroy' => "blog#destroyPage"

    match '/:pid/comment' => "blog#comment", :via=>"post"

    get '/:pid/destroy' => "blog#destroypost"
    get '/:pid' => 'blog#getpost'

  end

  root :to => 'home#index'
  
  get '/logout' => 'sessions#logout'
  match '/new' => 'home#new_get', :via => 'get'
  match '/new' => 'home#new_post', :via => 'post'
  match '/post' => 'blog#post_get', :via => 'get'
  match '/post' => 'blog#post_post', :via => 'post'
  get '/r' => "home#redirect"
  match '/kill' => "blog#killBlog", :via=>"get"
  match '/kill' => "blog#killBlog_post", :via=>"post"
  get '/help' => "home#help"
  get '/about' => "home#about"
  get '/dashboard' => "home#dashboard"
  get '/directory' => "home#directory"

  match '/page' => "blog#newPage", :via=>"get"
  match '/page' => "blog#newPage_post", :via=>"post"


  twitter = PostHub::Application.config.twitter_login
  twitter_endpoint = twitter.login_handler(:return_to => '/r')

  mount twitter_endpoint => 'login', :as => :login


end
