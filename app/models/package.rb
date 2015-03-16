class Package < ActiveRecord::Base
  belongs_to :user
 
  scope :common_attributes, -> { select('id, name, features, price')}
end
