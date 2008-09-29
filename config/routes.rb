ActionController::Routing::Routes.draw do |map|
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil 
  
  map.remind_password '/remind_password', :controller => 'users', :action => 'remind_password'
  map.recover_password '/recover_password', :controller => 'users', :action => 'recover_password'
 
  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete, :check_user_login=>:get, :check_user_email=>:get}  
  map.resource :session
   
  map.with_options(:controller => 'home', :conditions=>{ :subdomain => /^(?!www)/ }) do |home|
     home.home '/', :action => 'index'
  end
  
  map.main '/', :controller=>'content', :action=>'index' 
 
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
