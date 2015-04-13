class V1::ClubsController < ApplicationController
  before_filter :set_params, :only => [:index]
  before_action :authenticate_admin!, :only => [:create, :update, :destroy], :unless => :master_api_key?

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
    render :json => { :data => Club.search_attributes(params).main_index(params) }, :status => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :status => 422
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
