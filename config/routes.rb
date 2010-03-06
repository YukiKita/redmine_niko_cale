ActionController::Routing::Routes.draw do |map|
  map.connect 'projects/:project_id/niko_cale', :controller => 'niko_cale', :action => 'index'
  map.connect 'projects/:project_id/feelings', :controller => 'feelings', :action => 'index'
  map.connect 'projects/:project_id/feelings/show', :controller => 'feelings', :action => 'show'
  map.connect 'projects/:project_id/feelings/edit', :controller => 'feelings', :action => 'edit'
  map.connect 'projects/:project_id/feelings/edit_comment', :controller => 'feelings', :action => 'edit_comment'
end
