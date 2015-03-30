class V1::PackagesController < ApplicationController
  respond_to :json
  before_filter :set_params, :only => [:index]
  before_action :authenticate_user!, :only => [:create, :update, :destroy], :unless => :master_api_key?

  def create
    package = Package.new(package_params)

    if package.save
      render :json => { :data => Package.joins(:features).feature_attributes.find_by_id(package.id) }, :status => 201
    else
      render :json => { :errors => package.errors.full_messages.to_sentence }, :status => 422
    end
  end

  def destroy
    package = Package.find_by_id(params[:id])

    if package.blank?
      render :json => { :errors => "The package with id #{params[:id]} could not be found." }, :status => 422
    else
      package.destroy
      render :json => { :data => "The package with id #{params[:id]} has been deleted." }, :status => 202
    end
  end

  def index
    render :json => { :data => Package.feature_join.paginate(:page => params[:page], :per_page => params[:per_page]).feature_attributes.group("packages.id").all.order(params[:order_by] => params[:order_direction]) }, :status => 200
  end

  def show
    package = Package.joins(:features).feature_attributes.find_by_id(params[:id])

    if package.id != nil
      render :json => { :data => package }, :status => 200
    else
      render :json => { :errors => "The package with id #{params[:id]} could not be found." }, :status => 422
    end
  end

  def update
    package = Package.find_by_id(params[:id])

    if package.blank?
      render :json => { :errors => "The package with id #{params[:id]} could not be found." }, :status => 422
    elsif package.update(package_params)
      render :json => { :data => Package.joins(:features).feature_attributes.find_by_id(package.id) }, :status => 200
    else
      render :json => { :errors => package.errors.full_messages.to_sentence }, :status => 422
    end
  end

  private

  def package_params
    _params = params.require(:package).permit(
      :name, :description, :price, :credits, :featurizations_attributes => [:feature_id]
    )
  end
end
