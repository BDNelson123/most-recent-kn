require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :course do
    name "Cameron Park Country Club"
    address "3201 Royal Dr."
    address2 nil
    city "Cameron Park"
    state "CA"
    zip "95682"
  end
end
