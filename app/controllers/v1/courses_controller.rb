class V1::CoursesController < ApplicationController
  respond_to :json

  def index
    render :json => { :data => Course.common_attributes.all.order(:name => "ASC") }, :status => 200
  end

  def show
    course = Course.common_attributes.find_by_id(params[:id])

    if course
      render :json => { :data => course }, :status => 200
    else
      render :json => { :errors => "The course with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
