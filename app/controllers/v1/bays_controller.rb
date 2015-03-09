class V1::BaysController < ApplicationController
  respond_to :json

  def index
    render :json => Bay.all
  end

  def show
    render :json => Bay.find_by_id(params[:id])
  end
end
