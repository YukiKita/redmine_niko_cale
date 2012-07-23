RedmineApp::Application.routes.draw do
  match 'projects/:project_id/niko_cale', :to=> 'niko_cale#index'
  match 'feelings/edit_comment/:id', :to => 'feelings#edit_comment'
  match 'niko_cale_settings/preview', :to => 'niko_cale_settings#preview'
  resources :feelings 
end
