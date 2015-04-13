class V1::BayStatusesController < ApplicationController
  before_filter :set_params, :only => [:index]
  before_action :authenticate_admin!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    status = BayStatus.new(status_params)

    if status.save
      render :json => { :data => BayStatus.common_attributes.find_by_id(status.id) }, :status => 201
    else
      render :json => { :errors => status.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    status = BayStatus.find_by_id(params[:id])

    if status.blank?
      render :json => { :errors => "The bay status with id #{params[:id]} could not be found." }, :status => 422
    else
      status.destroy
      render :json => { :data => "The bay status with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => BayStatus.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    status = BayStatus.common_attributes.find_by_id(params[:id])

    if status
      render :json => { :data => status }, :status => 200
    else
      render :json => { :errors => "The bay status with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    status = BayStatus.find_by_id(params[:id])

    if status.blank?
      render :json => { :errors => "The bay status with id #{params[:id]} could not be found." }, :status => 422
    elsif status.update(status_params)
      render :json => { :data => BayStatus.common_attributes.find_by_id(status.id) }, :status => 200
    else
      render :json => { :errors => status.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def status_params
    _params = params.require(:bay_status).permit(
      :name, :description
    )
  end
end
