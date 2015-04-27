class V1::AssignmentsController < ApplicationController
  before_action -> { custom_authenticate_member(current_all) }, only: [:index, :show]
  before_action -> { custom_authenticate_member(current_employee_admin) }, only: [:create, :update, :destroy]

  def create
    assignment = Assignment.new(assignment_params)

    if assignment_params[:bay_id].present? && assignment_params[:bay_kind_id].present?
      render :json => { :errors => "Please specify a bay_kind_id or a bay_id, not both." }, :status => 422
    elsif assignment_params[:bay_kind_id].present?
      assignment_or_waiting(assignment,assignment_params)
    elsif assignment_params[:bay_id].present?
      if assignment.save
        render :json => { :data => Assignment.assignment_join.common_attributes.find_by_id(assignment.id) }, :status => 201
      else
        render :json => { :errors => assignment.errors.full_messages.to_sentence }, :status => 422
      end
    else
      render :json => { :errors => "Please specify a bay_kind_id or a bay_id." }, :status => 422
    end
  end

  def destroy
    assignment = Assignment.find_by_id(params[:id])

    if assignment.blank?
      render :json => { :errors => "The assignment with id #{params[:id]} could not be found." }, :status => 422
    elsif assignment.destroy
      render :json => { :data => "The assignment with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Assignment.assignment_join.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid" }, :status => 422
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

  def assignment_or_waiting(assignment,assignment_params)
    # check to see if bay exists with this bay_kind_id that is also available (bay_status_id == 2)
    bay = Bay.where(:bay_kind_id => assignment_params[:bay_kind_id], :bay_status_id => 2).floor_preference(assignment_params).number_preference(assignment_params).first

    if bay.present?
      assignment.bay_id = bay.id
      assignment.save
      render :json => { :message => "Assignment created", :data => Assignment.assignment_join.common_attributes.find_by_id(assignment.id) }, :status => 201
    else
      waiting = Waiting.create_from_assignment(assignment_params)

      if waiting.save
        render :json => { :message => "Waiting created", :data => waiting }, :status => 201
      else
        render :json => { :errors => waiting.errors.full_messages.to_sentence }, :status => 422
      end
    end
  end

  def assignment_params
    _params = params.require(:assignment).permit(
      :bay_id, :user_id, :credits_per_hour, :check_in_at, :duration,
      :check_out_at, :parent_id, :bay_kind_id, :floor, :number
    )
  end
end
