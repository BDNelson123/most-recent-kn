class Package < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  has_many :users
  has_many :featurizations, :dependent => :destroy
  has_many :features, :through => :featurizations
  accepts_nested_attributes_for :featurizations
  before_save :delete_duplicate_featurizations

  validates :name, :presence => true
  validates :description, :presence => true
  validates :price, :presence => true, :numericality => { :only_intger => true }
  validates :credits, :presence => true, :numericality => { :only_intger => true }
  
  scope :common_attributes, -> {select('packages.id,packages.name,packages.description,packages.price,packages.credits,group_concat(features.name) as package_features')}
  scope :feature_join, -> {joins('LEFT JOIN featurizations ON featurizations.package_id = packages.id LEFT JOIN features ON features.id = featurizations.feature_id')}

  scope :search_attributes, -> (params) { 
    if params[:search] != nil
      return where("packages.name LIKE ? OR packages.description LIKE ? OR packages.price LIKE ? OR packages.credits LIKE ? OR features.name LIKE ?", "%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%")
    end
    nil
  }

  def self.main_count(object)
    count = 0
    object.each do |o|
      count = count + 1
    end
    count
  end

  private

  # prevents duplicate featurization model records
  def delete_duplicate_featurizations
    Featurization.where(:package_id => self.id).delete_all
  end
end
