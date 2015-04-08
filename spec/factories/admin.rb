require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :admin do
    uid SecureRandom.uuid
    provider "email"
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password "test1234"
    password_confirmation "test1234"
  end
end
