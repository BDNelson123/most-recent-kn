class V1::WaitingsController < V1::ApiController
  before_action :authenticate_admin!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    waiting = Waiting.new(waiting_params)

    if waiting.save
      render :json => { :data => Waiting.waiting_join.common_attributes.find_by_id(waiting.id) }, :status => 201
    else
      render :json => { :errors => waiting.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    waiting = Waiting.find_by_id(params[:id])

    if waiting.blank?
      render :json => { :errors => "The waiting record with id #{params[:id]} could not be found." }, :status => 422
    elsif waiting.destroy
      render :json => { :data => "The waiting record with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Waiting.waiting_join.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    waiting = Waiting.waiting_join.common_attributes.find_by_id(params[:id])

    if waiting
      render :json => { :data => waiting }, :status => 200
    else
      render :json => { :errors => "The waiting record with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    waiting = Waiting.find_by_id(params[:id])

    if waiting.blank?
      render :json => { :errors => "The waiting record with id #{params[:id]} could not be found." }, :status => 422
    elsif waiting.update(waiting_params)
      render :json => { :data => Waiting.waiting_join.common_attributes.find_by_id(waiting.id) }, :status => 200
    else
      render :json => { :errors => waiting.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def waiting_params
    _params = params.require(:waiting).permit(
      :user_id, :bay_kind_id, :preference_floor, :preference_bay
    )
  end
end
