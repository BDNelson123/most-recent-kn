class Package < ActiveRecord::Base
  belongs_to :user
  has_many :featurizations
  has_many :features, :through => :featurizations
  accepts_nested_attributes_for :featurizations
  before_save :delete_duplicate_featurizations

  validates :name, :presence => true
  validates :description, :presence => true
  validates :price, :presence => true, :numericality => { :only_intger => true }
  validates :credits, :presence => true, :numericality => { :only_intger => true }
  
  scope :common_attributes, -> {select('id, name, description, price, credits')}
  scope :feature_attributes, -> {select('packages.id,packages.name,packages.description,packages.price,packages.credits,group_concat(features.name) as package_features')}
  scope :feature_join, -> {joins('LEFT JOIN featurizations ON featurizations.package_id = packages.id LEFT JOIN features ON features.id = featurizations.feature_id')}

  private

  # prevents duplicate featurization model records
  def delete_duplicate_featurizations
    Featurization.where(:package_id => self.id).delete_all
  end
end
