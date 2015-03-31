class Course < ActiveRecord::Base
  include ActiveRecordBaseExtensionScope

  belongs_to :user
  validates :name, :presence => true
  validates :address, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true

  scope :common_attributes, -> { select('id, name, address, address2, city, state, zip')}
end
