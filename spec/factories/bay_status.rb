require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :bay_status do
    name { Faker::Name.name }
    description { Faker::Company.bs }
  end
end
