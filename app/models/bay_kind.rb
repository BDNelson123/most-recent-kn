class BayKind < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  has_many :bays

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :description, :presence => true
  validates :credits_per_hour, :presence => true, :numericality => { :only_integer => true }

  scope :common_attributes, -> { select('id, name, description, credits_per_hour')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("bay_kinds.name LIKE ? OR bay_kinds.description LIKE ? OR bay_kinds.credits_per_hour LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    nil
  }
end
