class V1::BaysController < ApplicationController
  devise_token_auth_group :all, contains: [:user, :employee, :admin]
  before_filter :set_params, :only => [:index]
  before_action :authenticate_admin!, :only => [:create, :destroy, :update], :unless => :master_api_key?
  before_action -> { custom_authenticate_member(current_all) }, only: [:index, :show]

  def create
    bay = Bay.new(bay_params)

    if bay.save
      render :json => { :data => Bay.joins(:bay_status, :bay_type).common_attributes.find_by_id(bay.id) }, :status => 201
    else
      render :json => { :errors => bay.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    bay = Bay.find_by_id(params[:id])

    if bay.blank?
      render :json => { :errors => "The bay with id #{params[:id]} could not be found." }, :status => 422
    else
      bay.destroy
      render :json => { :data => "The bay with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Bay.joins(:bay_status, :bay_type).search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    bay = Bay.joins(:bay_status, :bay_type).common_attributes.find_by_id(params[:id])

    if bay.id != nil
      render :json => { :data => bay }, :status => 200
    else
      render :json => { :errors => "The bay with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    bay = Bay.find_by_id(params[:id])

    if bay.blank?
      render :json => { :errors => "The bay with id #{params[:id]} could not be found." }, :status => 422
    elsif bay.update(bay_params)
      render :json => { :data => Bay.joins(:features).common_attributes.find_by_id(bay.id) }, :status => 200
    else
      render :json => { :errors => bay.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def bay_params
    _params = params.require(:bay).permit(
      :number, :bay_status_id, :bay_type_id 
    )
  end
end
