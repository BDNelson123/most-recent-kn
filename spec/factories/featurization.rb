require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :featurization do
    feature_id 1
    package_id 1
  end
end
