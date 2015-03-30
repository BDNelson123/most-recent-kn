class V1::UsersController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:index, :show, :destroy], :unless => :master_api_key?

  def index
    render :json => { :data => User.paginate(:page => params[:page], :per_page => params[:per_page]).common_attributes.all.order(params[:order_by] => params[:order_direction]) }, :status => 200
  end

  def show
    user = User.common_attributes.find_by_id(params[:id])

    if user
      render :json => { :data => user }, :status => 200
    else
      render :json => { :errors => "The user with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def destroy
    user = User.common_attributes.find_by_id(params[:id])

    if user.blank?
      render :json => { :errors => "The user with id #{params[:id]} could not be found." }, :status => 422
    else
      user.destroy
      render :json => { :data => "The user with id #{params[:id]} has been deleted." }, :status => 202
    end
  end
end
