class V1::LevelsController < ApplicationController
  respond_to :json
  before_action :authenticate_user!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    level = Level.new(level_params)

    if level.save
      render :json => { :data => Level.common_attributes.find_by_id(level.id) }, :status => 201
    else
      render :json => { :errors => level.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def index
    render :json => { :data => Level.common_attributes.all.order(:id => "DESC") }, :status => 200
  end

  def show
    level = Level.common_attributes.find_by_id(params[:id])

    if level
      render :json => { :data => level }, :status => 200
    else
      render :json => { :errors => "The level with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  private

  def level_params
    _params = params.require(:level).permit(
      :name, :description, :handicap
    )
  end
end
