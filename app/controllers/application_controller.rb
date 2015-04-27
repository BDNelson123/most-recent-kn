class ApplicationController < ActionController::Base
  respond_to :json
  include DeviseTokenAuth::Concerns::SetUserByToken
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
end
