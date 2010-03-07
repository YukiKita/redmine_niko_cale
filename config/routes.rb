ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/niko_cale', :controller => 'niko_cale', :action => 'index'
  map.resources :feelings 
end
