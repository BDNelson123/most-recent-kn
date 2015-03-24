class V1::ClubsController < ApplicationController
  respond_to :json

  def index
    render :json => { :data => Club.common_attributes.all.order(:name => "ASC") }, :status => 200
  end

  def show
    club = Club.common_attributes.find_by_id(params[:id])

    if club
      render :json => { :data => club }, :status => 200
    else
      render :json => { :errors => "The club with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
