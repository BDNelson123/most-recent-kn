class Feature < ActiveRecord::Base
  has_many :featurizations
  has_many :packages, :through => :featurizations

  validates :name, :presence => true
  validates_uniqueness_of :name, :case_sensitive => false
end
