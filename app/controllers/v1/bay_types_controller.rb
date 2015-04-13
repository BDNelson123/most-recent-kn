class V1::BayTypesController < ApplicationController
  before_filter :set_params, :only => [:index]
  before_action :authenticate_admin!, :only => [:create, :delete, :update], :unless => :master_api_key?

  def create
    type = BayType.new(type_params)

    if type.save
      render :json => { :data => BayType.common_attributes.find_by_id(type.id) }, :type => 201
    else
      render :json => { :errors => type.errors.full_messages.to_sentence }, :type => 422
    end
  end

  def destroy
    type = BayType.find_by_id(params[:id])

    if type.blank?
      render :json => { :errors => "The bay type with id #{params[:id]} could not be found." }, :type => 422
    else
      type.destroy
      render :json => { :data => "The bay type with id #{params[:id]} has been deleted." }, :type => 202
    end
  end

  def index
    render :json => { :data => BayType.search_attributes(params).main_index(params) }, :type => 200
  rescue ActiveRecord::StatementInvalid => error
    render :json => { :errors => "Your query is invalid." }, :type => 422
  end

  def show
    type = BayType.common_attributes.find_by_id(params[:id])

    if type
      render :json => { :data => type }, :type => 200
    else
      render :json => { :errors => "The bay type with id #{params[:id]} could not be found." }, :type => 422
    end
  end

  def update
    type = BayType.find_by_id(params[:id])

    if type.blank?
      render :json => { :errors => "The bay type with id #{params[:id]} could not be found." }, :type => 422
    elsif type.update(type_params)
      render :json => { :data => BayType.common_attributes.find_by_id(type.id) }, :type => 200
    else
      render :json => { :errors => type.errors.full_messages.to_sentence }, :type => 422
    end
  end

  private

  def type_params
    _params = params.require(:type).permit(
      :name, :description
    )
  end
end
