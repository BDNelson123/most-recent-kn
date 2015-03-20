class V1::PackagesController < ApplicationController
  respond_to :json

  def index
    render :json => Package.feature_join.feature_attributes.group("packages.id").all
  end

  def show
    package = Package.joins(:features).feature_attributes.find_by_id(params[:id])

    if package
      render :json => package
    else
      render :json => { :errors => "The package with id #{params[:id]} could not be found." }, :status => 422
    end
  end
end
