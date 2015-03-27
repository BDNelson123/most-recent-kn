require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :level do
    name { Faker::Company.bs }
    description { Faker::Company.catch_phrase }
    handicap { Faker::Company.catch_phrase }
  end
end
