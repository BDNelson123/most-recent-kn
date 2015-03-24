require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :package do
    name "Bronze"
    description "FlyingTee Membership card"
    price "22.0"
    credits 20
  end
end
