class V1::CoursesController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    course = Course.new(course_params)

    if course.save
      render :json => { :data => Course.common_attributes.find_by_id(course.id) }, :status => 201
    else
      render :json => { :errors => course.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def index
    render :json => { :data => Course.main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def destroy
    course = Course.find_by_id(params[:id])

    if course.blank?
      render :json => { :errors => "The course with id #{params[:id]} could not be found." }, :status => 422
    else
      course.destroy
      render :json => { :data => "The course with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def show
    course = Course.common_attributes.find_by_id(params[:id])

    if course
      render :json => { :data => course }, :status => 200
    else
      render :json => { :errors => "The course with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    course = Course.find_by_id(params[:id])

    if course.blank?
      render :json => { :errors => "The course with id #{params[:id]} could not be found." }, :status => 422
    elsif course.update(course_params)
      render :json => { :data => Course.common_attributes.find_by_id(course.id) }, :status => 200
    else
      render :json => { :errors => course.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def course_params
    _params = params.require(:course).permit(
      :name, :address, :address2, :city, :state, :zip
    )
  end
end
