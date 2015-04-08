Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  as :auth do
  end

  mount_devise_token_auth_for 'Admin', at: 'admin'
  as :admin do
  end

  mount_devise_token_auth_for 'Employee', at: 'employee'
  as :employee do
  end

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
