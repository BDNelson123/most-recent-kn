require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :package do
    name { Faker::Name.first_name }
    description { Faker::Company.catch_phrase }
    price { Faker::Commerce.price }
    credits { Faker::Number.digit }
    features []
  end
end
