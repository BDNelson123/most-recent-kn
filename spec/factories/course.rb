require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :course do
    name { Faker::Company.name }
    address { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
  end
end
