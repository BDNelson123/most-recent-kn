class Income < ActiveRecord::Base
  belongs_to :user
  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
 
  scope :common_attributes, -> { select('id, name')}
end
