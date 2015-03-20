class Feature < ActiveRecord::Base
  has_many :featurizations
  has_many :packages, :through => :featurizations
end
