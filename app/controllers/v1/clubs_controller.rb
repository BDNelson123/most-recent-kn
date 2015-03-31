class V1::ClubsController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    club = Club.new(club_params)

    if club.save
      render :json => { :data => Club.common_attributes.find_by_id(club.id) }, :status => 201
    else
      render :json => { :errors => club.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    club = Club.find_by_id(params[:id])

    if club.blank?
      render :json => { :errors => "The club with id #{params[:id]} could not be found." }, :status => 422
    else
      club.destroy
      render :json => { :data => "The club with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    if params[:count] == "true"
      render :json => { :data => { :count => Club.where_attributes(params).count } }
    else
      render :json => { :data => Club.where_attributes(params).paginate(:page => params[:page], :per_page => params[:per_page]).common_attributes.all.order(params[:order_by] => params[:order_direction]) }, :status => 200
    end
  end

  def show
    club = Club.common_attributes.find_by_id(params[:id])

    if club
      render :json => { :data => club }, :status => 200
    else
      render :json => { :errors => "The club with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    club = Club.find_by_id(params[:id])

    if club.blank?
      render :json => { :errors => "The club with id #{params[:id]} could not be found." }, :status => 422
    elsif club.update(club_params)
      render :json => { :data => Club.common_attributes.find_by_id(club.id) }, :status => 200
    else
      render :json => { :errors => club.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def club_params
    _params = params.require(:club).permit(
      :name
    )
  end
end
