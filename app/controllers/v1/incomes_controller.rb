class V1::IncomesController < ApplicationController
  respond_to :json

  def index
    render :json => { :data => Income.common_attributes.all.order(:id => "ASC") }, :status => 200
  end

  def show
    income = Income.common_attributes.find_by_id(params[:id])

    if income
      render :json => { :data => income }, :status => 200
    else
      render :json => { :errors => "The income with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
