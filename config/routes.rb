Rails.application.routes.draw do
  match 'projects/:project_id/niko_cale', to: 'niko_cale#index', via: [:get]
  match 'feelings/edit_comment/:id', to: 'feelings#edit_comment', via: [:patch, :put, :post, :get, :delete]
  match 'niko_cale_settings/preview', to: 'niko_cale_settings#preview', via: [:get, :post]
  resources :feelings
end
