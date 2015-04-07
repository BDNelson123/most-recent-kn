Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  namespace :v1 do
    resources :assignments
    resources :bays
    resources :clubs
    resources :courses
    resources :features
    resources :incomes
    resources :levels
    resources :packages
    resources :users
  end
end
