class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :configure_permitted_parameters, if: :devise_controller?
  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [
      :name, :address, :address2, 
      :city, :state, :zip, 
      :phone, :handedness, :dob, 
      :owns_clubs, :gender, :wood_club_id, 
      :iron_club_id, :level_id, :income_id, 
      :email_optin, :terms_accepted
    ]
  end

  # this is a hack for testing on production
  def master_api_key?
    params[:master_api_key] == "thisisatest"
  end
end
