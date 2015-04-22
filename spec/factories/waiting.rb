require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :waiting do
    user_id 1
    bay_kind_id 1
    floor nil
    number nil
    parent_id nil
    credits_per_hour 1
    duration 30
  end
end
