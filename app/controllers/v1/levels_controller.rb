class V1::LevelsController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    level = Level.new(level_params)

    if level.save
      render :json => { :data => Level.common_attributes.find_by_id(level.id) }, :status => 201
    else
      render :json => { :errors => level.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    level = Level.find_by_id(params[:id])

    if level.blank?
      render :json => { :errors => "The level with id #{params[:id]} could not be found." }, :status => 422
    else
      level.destroy
      render :json => { :data => "The level with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Level.paginate(:page => params[:page], :per_page => params[:per_page]).common_attributes.all.order(params[:order_by] => params[:order_direction]) }, :status => 200
  end

  def show
    level = Level.common_attributes.find_by_id(params[:id])

    if level
      render :json => { :data => level }, :status => 200
    else
      render :json => { :errors => "The level with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    level = Level.find_by_id(params[:id])

    if level.blank?
      render :json => { :errors => "The level with id #{params[:id]} could not be found." }, :status => 422
    elsif level.update(level_params)
      render :json => { :data => Level.common_attributes.find_by_id(level.id) }, :status => 200
    else
      render :json => { :errors => level.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def level_params
    _params = params.require(:level).permit(
      :name, :description, :handicap
    )
  end
end
