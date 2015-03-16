class Level < ActiveRecord::Base
  belongs_to :user
 
  scope :common_attributes, -> { select('id, name, handicap, description')}
end
