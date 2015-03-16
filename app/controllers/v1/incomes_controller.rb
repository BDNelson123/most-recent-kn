class V1::IncomesController < ApplicationController
  respond_to :json

  def index
    render :json => Income.common_attributes.all.order(:id => "ASC")
  end

  def show
    income = Income.common_attributes.find_by_id(params[:id])

    if income
      render :json => income
    else
      render :json => { :errors => "The income with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
