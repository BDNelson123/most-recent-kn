require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :level do
    name "Touring Pro"
    description "Scratch Golfer"
    handicap 0
  end
end
