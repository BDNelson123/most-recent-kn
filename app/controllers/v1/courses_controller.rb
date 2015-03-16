class V1::CoursesController < ApplicationController
  respond_to :json

  def index
    render :json => Course.common_attributes.all
  end

  def show
    render :json => Course.common_attributes.find_by_id(params[:id])
  end
end
