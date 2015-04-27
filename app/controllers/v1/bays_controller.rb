class V1::BaysController < V1::ApiController
  before_action :authenticate_admin!, :only => [:create, :destroy], :unless => :master_api_key?
  before_action -> { custom_authenticate_member(current_all) }, only: [:index, :show]
  before_action -> { custom_authenticate_member(current_employee_admin) }, only: [:update]

  def create
    bay = Bay.new(bay_params)

    if bay.save
      render :json => { :data => Bay.joins(:bay_status,:bay_kind).common_attributes.find_by_id(bay.id) }, :status => 201
    else
      render :json => { :errors => bay.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    bay = Bay.find_by_id(params[:id])

    if bay.blank?
      render :json => { :errors => "The bay with id #{params[:id]} could not be found." }, :status => 422
    elsif bay.destroy
      render :json => { :data => "The bay with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Bay.joins(:bay_status,:bay_kind).search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    bay = Bay.joins(:bay_status, :bay_kind).common_attributes.find_by_id(params[:id])

    if bay.id != nil
      render :json => { :data => bay }, :status => 200
    else
      render :json => { :errors => "The bay with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    bay = Bay.find_by_id(params[:id])
    status = bay.bay_status_id.to_i

    if bay.blank?
      render :json => { :errors => "The bay with id #{params[:id]} could not be found." }, :status => 422
    elsif bay.update(bay_update_params)
      waiting = Waiting.where(:bay_kind_id => bay.bay_kind_id.to_i).order("id DESC").first
      assignment_waiting_crud(bay_update_params,params,bay,waiting,status)
    else
      render :json => { :errors => bay.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def assignment_waiting_crud(bay_update_params,params,bay,waiting,status)
    # if bay is changed to available, then we see if someone is waiting on it and we create an assignment for them and delete the waiting record
    if bay_update_params[:bay_status_id] == 2
      if waiting.present? && Bay.bay_waiting(bay,waiting,status) == true
        Assignment.create(
          :bay_id => params[:id].to_i, 
          :user_id => waiting.user_id.to_i, 
          :credits_per_hour => waiting.credits_per_hour.to_i, 
          :check_in_at => DateTime.now, 
          :check_out_at => DateTime.now + waiting.duration.minutes
        )
        waiting.destroy
        render :json => {
          :message => "Assignment created for waiting player #{waiting.user_id} at #{params[:id]}", 
          :data => Bay.joins(:bay_status,:bay_kind).common_attributes.find_by_id(bay.id)
        }, :status => 200
      end
    else
      # if bay is changed to bussing, then we will destroy the assignments associated with that bay
      Assignment.where(:bay_id => params[:id]).destroy_all if bay_update_params[:bay_status_id] == 5
      render :json => { :data => Bay.joins(:bay_status,:bay_kind).common_attributes.find_by_id(bay.id) }, :status => 200
    end
  end

  def bay_params
    _params = params.require(:bay).permit(
      :number, :floor, :bay_status_id, :bay_kind_id
    )
  end

  def bay_update_params
    _params = params.require(:bay).permit(
      :bay_status_id
    )
  end
end
