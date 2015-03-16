class Income < ActiveRecord::Base
  belongs_to :user
 
  scope :common_attributes, -> { select('id, name')}
end
