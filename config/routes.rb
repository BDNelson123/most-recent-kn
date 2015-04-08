Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'user_auth'
  as :user_auth do
  end

  mount_devise_token_auth_for 'Admin', at: 'admin_auth'
  as :admin_auth do
  end

  mount_devise_token_auth_for 'Employee', at: 'employee_auth'
  as :employee_auth do
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
