Rails.application.routes.draw do
  namespace :admin do
    resource :xero_settings do
      get :test, :on => :collection
    end
  end
end
