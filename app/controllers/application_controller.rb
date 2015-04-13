class ApplicationController < ActionController::Base
  respond_to :json
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # devise strong parameters for sign_up
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [
      :name, :address, :address2, :city, :state, :zip, 
      :phone, :handedness, :dob, :owns_clubs, :gender, :wood_club_id, 
      :iron_club_id, :level_id, :income_id, :email_optin, :terms_accepted
    ]
  end

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
