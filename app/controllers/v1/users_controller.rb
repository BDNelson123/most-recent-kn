class V1::UsersController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:index, :show, :destroy], :unless => :master_api_key?

  def index
    render :json => { :data => User.user_join.search_attributes(params).user_group(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    user = User.user_join.common_attributes.find_by_id(params[:id])

    if user.id == nil
      render :json => { :errors => "The user with id #{params[:id]} could not be found." }, :status => 422
    else
      render :json => { :data => user }, :status => 200
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
