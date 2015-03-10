require 'spec_helper'

describe "user login", :type => :request do
  # building the club objects needed for testing
  before(:all) do
    @club1 = FactoryGirl.create(:club)
    @club2 = FactoryGirl.create(:club, :name => "Adams Golf")
  end

  # destroying the club objects after tests run
  after(:all) do
    Club.destroy_all
    User.destroy_all
  end

  describe "#create" do
    it "" do
      post '/auth', { 
        "name" => Faker::Name.name, "address" => Faker::Address.street_address, "address2" => Faker::Address.secondary_address, 
        "city" => Faker::Address.city, "state" => Faker::Address.state_abbr, "zip" => Faker::Address.zip,
        "phone" => "18067770259", "dob" => "1-1-1985", "handedness" => false,
        "owns_clubs" => false, "iron_club_id" => @club1.id, "wood_club_id" => @club2.id,
        "gender" => false, "email" => Faker::Internet.email, "password" => "test1234", "password_confirmation" => "test1234", 
        "confirm_success_url" => true
      }
      pp response.status
    end
  end
end
