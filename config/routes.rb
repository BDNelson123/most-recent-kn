Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  namespace :v1 do
    resources :clubs
    resources :courses
    resources :levels
    resources :packages
    resources :bays
    resources :assignments
    resources :users
  end
end
