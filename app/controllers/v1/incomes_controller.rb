class V1::IncomesController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    income = Income.new(income_params)

    if income.save
      render :json => { :data => Income.common_attributes.find_by_id(income.id) }, :status => 201
    else
      render :json => { :errors => income.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    income = Income.find_by_id(params[:id])

    if income.blank?
      render :json => { :errors => "The income with id #{params[:id]} could not be found." }, :status => 422
    else
      income.destroy
      render :json => { :data => "The income with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Income.paginate(:page => params[:page], :per_page => params[:per_page]).common_attributes.all.order(params[:order_by] => params[:order_direction]) }, :status => 200
  end

  def show
    income = Income.common_attributes.find_by_id(params[:id])

    if income
      render :json => { :data => income }, :status => 200
    else
      render :json => { :errors => "The income with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    income = Income.find_by_id(params[:id])

    if income.blank?
      render :json => { :errors => "The income with id #{params[:id]} could not be found." }, :status => 422
    elsif income.update(income_params)
      render :json => { :data => Income.common_attributes.find_by_id(income.id) }, :status => 200
    else
      render :json => { :errors => income.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def income_params
    _params = params.require(:income).permit(
      :name, :description
    )
  end
end
