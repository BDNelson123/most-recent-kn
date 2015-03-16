class V1::PackagesController < ApplicationController
  respond_to :json

  def index
    render :json => Package.common_attributes.all.order(:id => "ASC")
  end

  def show
    package = Package.common_attributes.find_by_id(params[:id])

    if package
      render :json => package
    else
      render :json => { :errors => "The package with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
