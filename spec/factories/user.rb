require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :user do
    uid SecureRandom.uuid
    provider "email"
    name { Faker::Name.name }
    address { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    phone "18067770259"
    dob "1-1-1985"
    handedness true
    owns_clubs false
    iron_club_id 1
    wood_club_id 1
    email_optin true
    terms_accepted true
    level_id 1
    income_id 1
    gender false
    email { Faker::Internet.email }
    password "test1234"
    password_confirmation "test1234"
  end
end
