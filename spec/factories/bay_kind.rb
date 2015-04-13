require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :bay_kind do
    name { Faker::Company.name }
    description { Faker::Company.bs }
    credits_per_hour { Faker::Number.digit }
  end
end
