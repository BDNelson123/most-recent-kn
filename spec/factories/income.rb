require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :income do
    name "Under $20,000"
    description nil
  end
end
