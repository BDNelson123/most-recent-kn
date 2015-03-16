class V1::IncomesController < ApplicationController
  respond_to :json

  def index
    render :json => Income.common_attributes.all
  end

  def show
    render :json => Income.common_attributes.find_by_id(params[:id])
  end
end
