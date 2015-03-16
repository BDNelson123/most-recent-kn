class V1::ClubsController < ApplicationController
  respond_to :json

  def index
    render :json => Club.common_attributes.all
  end

  def show
    render :json => Club.common_attributes.find_by_id(params[:id])
  end
end
