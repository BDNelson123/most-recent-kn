require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :income do
    name { Faker::Company.catch_phrase }
    description nil
  end
end
