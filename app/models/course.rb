class Course < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :user
  validates :name, :presence => true
  validates :address, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true

  scope :common_attributes, -> { select('id, name, address, address2, city, state, zip')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("courses.name LIKE ? OR courses.address LIKE ? OR courses.address2 LIKE ? OR courses.city LIKE ? OR courses.state LIKE ? OR courses.zip LIKE ?", "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%")
    end
    nil
  }
end
