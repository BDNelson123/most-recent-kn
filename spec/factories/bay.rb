require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :bay do
    number { Faker::Number.number(9) }
    floor 1
    bay_kind_id { Faker::Number.number(9) }
    bay_status_id { Faker::Number.number(9) }
  end
end
