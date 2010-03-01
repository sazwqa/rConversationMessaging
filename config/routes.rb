ActionController::Routing::Routes.draw do |map|
  
  map.inbox '/inbox', :controller => 'messages', :action => 'inbox'
  map.outbox '/outbox', :controller => 'messages', :action => 'outbox'
  map.compose '/compose', :controller => 'messages', :action => 'compose'
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users

  map.resource :session
  map.root :controller => 'sessions', :action => 'new'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
