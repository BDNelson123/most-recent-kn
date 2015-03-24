class V1::LevelsController < ApplicationController
  respond_to :json

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
end
