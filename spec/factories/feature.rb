require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :feature do
    name { Faker::Company.bs }
  end
end
