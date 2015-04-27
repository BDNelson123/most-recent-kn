class V1::BayKindsController < V1::ApiController
  before_action :authenticate_admin!, :only => [:create, :destroy, :update], :unless => :master_api_key?

  def create
    kind = BayKind.new(bay_kind_params)

    if kind.save
      render :json => { :data => BayKind.common_attributes.find_by_id(kind.id) }, :status => 201
    else
      render :json => { :errors => kind.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    kind = BayKind.find_by_id(params[:id])

    if kind.blank?
      render :json => { :errors => "The bay kind with id #{params[:id]} could not be found." }, :status => 422
    elsif kind.destroy
      render :json => { :data => "The bay kind with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => BayKind.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    kind = BayKind.common_attributes.find_by_id(params[:id])

    if kind
      render :json => { :data => kind }, :status => 200
    else
      render :json => { :errors => "The bay kind with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    kind = BayKind.find_by_id(params[:id])

    if kind.blank?
      render :json => { :errors => "The bay kind with id #{params[:id]} could not be found." }, :status => 422
    elsif kind.update(bay_kind_params)
      render :json => { :data => BayKind.common_attributes.find_by_id(kind.id) }, :status => 200
    else
      render :json => { :errors => kind.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def bay_kind_params
    _params = params.require(:bay_kind).permit(
      :name, :description, :credits_per_hour
    )
  end
end
