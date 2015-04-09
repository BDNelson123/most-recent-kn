class BayStatus < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  has_many :bays

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :description, :presence => true

  scope :common_attributes, -> { select('id, name, description')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("bay_statuses.name LIKE ? OR bay_statuses.description LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    nil
  }
end
