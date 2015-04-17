require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :assignment do
    bay_id { Faker::Number.digit }
    user_id { Faker::Number.digit }
    credits_per_hour { Faker::Number.number(2) }
    check_in_at DateTime.now + 12.hours
    check_out_at DateTime.now + 13.hours
  end
end
