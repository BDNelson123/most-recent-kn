class Level < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  has_many :users 

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :description, :presence => true
  validates :handicap, :presence => true
 
  scope :common_attributes, -> { select('id, name, handicap, description')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("levels.name LIKE ? OR levels.handicap LIKE ? OR levels.description LIKE ?", "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%")
    end
    nil
  }
end
