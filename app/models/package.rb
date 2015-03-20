class Package < ActiveRecord::Base
  belongs_to :user
  has_many :featurizations
  has_many :features, :through => :featurizations
  
  scope :common_attributes, -> {select('id, name, description, price')}
  scope :feature_attributes, -> {select('packages.id,packages.description,packages.price,group_concat(features.description) as package_features')}
end
