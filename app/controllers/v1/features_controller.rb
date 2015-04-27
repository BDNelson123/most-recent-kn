class V1::FeaturesController < V1::ApiController
  before_action :authenticate_admin!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    feature = Feature.new(feature_params)

    if feature.save
      render :json => { :data => Feature.common_attributes.find_by_id(feature.id) }, :status => 201
    else
      render :json => { :errors => feature.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    feature = Feature.find_by_id(params[:id])

    if feature.blank?
      render :json => { :errors => "The feature with id #{params[:id]} could not be found." }, :status => 422
    elsif feature.destroy
      render :json => { :data => "The feature with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Feature.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
  end

  def show
    feature = Feature.common_attributes.find_by_id(params[:id])

    if feature
      render :json => { :data => feature }, :status => 200
    else
      render :json => { :errors => "The feature with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    feature = Feature.find_by_id(params[:id])

    if feature.blank?
      render :json => { :errors => "The feature with id #{params[:id]} could not be found." }, :status => 422
    elsif feature.update(feature_params)
      render :json => { :data => Feature.common_attributes.find_by_id(feature.id) }, :status => 200
    else
      render :json => { :errors => feature.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def feature_params
    _params = params.require(:feature).permit(
      :name
    )
  end
end
