class Featurization < ActiveRecord::Base
  belongs_to :package
  belongs_to :feature

  validates :feature_id, :presence => true, :numericality => { :only_intger => true }
  validates_model_id :feature_id, :message => "must have a valid id", :model => Feature
end
