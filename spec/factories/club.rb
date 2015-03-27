require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :club do
    name { Faker::Company.name }
  end
end
