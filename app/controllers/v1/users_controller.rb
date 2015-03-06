class V1::UsersController < ApplicationController
  respond_to :json

  def index
    render :json => User.common_attributes
  end

  def show
    render :json => User.common_attributes.find_by_id(params[:id])
  end

  def destroy
    render :json => User.destroy(params[:id])
  end
end
