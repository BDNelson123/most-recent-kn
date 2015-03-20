class Featurization < ActiveRecord::Base
  belongs_to :package
  belongs_to :feature
end
