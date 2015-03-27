class Level < ActiveRecord::Base
  belongs_to :user
  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
  validates :description, :presence => true
  validates :handicap, :presence => true
 
  scope :common_attributes, -> { select('id, name, handicap, description')}
end
