class V1::ApiController < ApplicationController
  before_filter :set_params, :only => [:index]
  devise_token_auth_group :all, contains: [:user, :employee, :admin]
  devise_token_auth_group :employee_admin, contains: [:employee, :admin]

  protected

  # this is a hack for testing on production
  def master_api_key?
    params[:master_api_key] == "thisisatest"
  end

  # defaults for index paginations
  def set_params
    params[:page] ||= 1
    params[:per_page] ||= 15
    params[:order_by] ||= "id"
    params[:order_direction] ||= "ASC"
  end

  # hack for devise groups
  def custom_authenticate_member(current_member)
    if current_member == nil && params[:master_api_key] != "thisisatest" 
      render :json => { :errors => ["Authorized users only."] }, status: 401	
    end
  end
end
