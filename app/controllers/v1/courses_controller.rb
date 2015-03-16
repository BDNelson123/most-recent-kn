class V1::CoursesController < ApplicationController
  respond_to :json

  def index
    render :json => Course.common_attributes.all.order(:name => "ASC")
  end

  def show
    course = Course.common_attributes.find_by_id(params[:id])

    if course
      render :json => course
    else
      render :json => { :errors => "The course with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
