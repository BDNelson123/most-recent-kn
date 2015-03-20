class Package < ActiveRecord::Base
  belongs_to :user
  has_many :featurizations
  has_many :features, :through => :featurizations
  
  scope :common_attributes, -> {select('id, name, description, price')}
  scope :feature_attributes, -> {select('packages.id,packages.description,packages.price,group_concat(features.description) as package_features')}
  scope :feature_join, -> {joins('LEFT JOIN featurizations ON featurizations.package_id = packages.id LEFT JOIN features ON features.id = featurizations.feature_id')}
end
