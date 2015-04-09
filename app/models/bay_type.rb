class BayType < ActiveRecord::Base
  has_many :bays

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :description, :presence => true
  validates :credits_per_hour, :presence => true

  scope :common_attributes, -> { select('id, name, description, credits_per_hour')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("clubs.name LIKE ?", "%#{params[:search]}%")
    end
    nil
end
