require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :package do
    name "Bronze"
    description nil
    features ["FlyingTee Membership card", "20 credits"]
    price "22.0"
  end
end
