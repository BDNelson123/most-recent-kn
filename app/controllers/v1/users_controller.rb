class V1::UsersController < ApplicationController
  respond_to :json

  before_action :authenticate_user!, :only => [:index, :show, :destroy]

  def index
    render :json => User.common_attributes
  end

  def show
    user = User.common_attributes.find_by_id(params[:id])

    if user
      render json: user
    else
      render json: "This user was not found.", :status => :unprocessable_entity
    end
  end

  def destroy
    user = User.common_attributes.find_by_id(params[:id])

    if user
      render :json => User.destroy(params[:id])
    else
      render json: "This user was not found.", :status => :unprocessable_entity
    end
  end
end
