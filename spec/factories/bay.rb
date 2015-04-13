require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :bay do
    number { Faker::Address.building_number }
    bay_kind_id { Faker::Number.number(2) }
    bay_status_id { Faker::Number.number(2) }
  end
end
