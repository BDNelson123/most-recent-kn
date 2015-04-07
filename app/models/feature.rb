class Feature < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  has_many :featurizations, :dependent => :destroy
  has_many :packages, :through => :featurizations

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
 
  scope :common_attributes, -> { select('id, name')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("features.name LIKE ?", "%#{params[:search]}%")
    end
    nil
  }
end
