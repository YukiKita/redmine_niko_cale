ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/niko_cale', :controller => 'niko_cale', :action => 'index'
  map.connect 'feelings/edit_comment/:id', :controller => 'feelings', :action => 'edit_comment'
  map.connect 'niko_cale_settings/preview', :controller => 'niko_cale_settings', :action => 'preview'
  map.resources :feelings 
end
