class V1::PackagesController < ApplicationController
  respond_to :json

  def index
    render :json => Package.common_attributes.all
  end

  def show
    render :json => Package.common_attributes.find_by_id(params[:id])
  end
end
