class V1::AssignmentsController < ApplicationController
  before_filter :set_params, :only => [:index]
  devise_token_auth_group :all, contains: [:user, :employee, :admin]
  devise_token_auth_group :employee_admin, contains: [:employee, :admin]
  before_action -> { custom_authenticate_member(current_all) }, only: [:index, :show]
  before_action -> { custom_authenticate_member(current_employee_admin) }, only: [:create, :update, :destroy]

  def create
    assignment = Assignment.new(assignment_params)

    if assignment.save
      render :json => { :data => Assignment.assignment_join.common_attributes.find_by_id(assignment.id) }, :status => 201
    else
      render :json => { :errors => assignment.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    assignment = Assignment.find_by_id(params[:id])

    if assignment.blank?
      render :json => { :errors => "The assignment with id #{params[:id]} could not be found." }, :status => 422
    else
      assignment.destroy
      render :json => { :data => "The assignment with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Assignment.assignment_join.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    assignment = Assignment.assignment_join.common_attributes.find_by_id(params[:id])

    if assignment
      render :json => { :data => assignment }, :status => 200
    else
      render :json => { :errors => "The assignment with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    assignment = Assignment.find_by_id(params[:id])

    if assignment.blank?
      render :json => { :errors => "The assignment with id #{params[:id]} could not be found." }, :status => 422
    elsif assignment.update(assignment_params)
      render :json => { :data => Assignment.assignment_join.common_attributes.find_by_id(assignment.id) }, :status => 200
    else
      render :json => { :errors => assignment.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def assignment_params
    _params = params.require(:assignment).permit(
      :bay_id, :user_id, :credits_per_hour, :check_in_at, :check_out_at, :parent_id
    )
  end
end
