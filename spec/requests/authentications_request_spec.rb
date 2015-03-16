require 'spec_helper'

describe "user authentication", :type => :request do
  before(:all) do
    # building the club/level/income objects needed for testing
    @club1 = FactoryGirl.create(:club)
    @club2 = FactoryGirl.create(:club, :name => "Adams Golf")
    @level = FactoryGirl.create(:level)
    @income = FactoryGirl.create(:income)

    @user_create_hash = { 
      "name" => Faker::Name.name, "address" => Faker::Address.street_address, "address2" => Faker::Address.secondary_address, 
      "city" => Faker::Address.city, "state" => Faker::Address.state_abbr, "zip" => Faker::Address.zip,
      "phone" => "18067770259", "dob" => "1-1-1985", "handedness" => false,
      "owns_clubs" => false, "iron_club_id" => @club1.id, "wood_club_id" => @club2.id,
      "gender" => false, "email" => Faker::Internet.email, "password" => "test1234", "password_confirmation" => "test1234", 
      "confirm_success_url" => true, "email_optin" => true, "terms_accepted" => true, "level_id" => @level.id, "income_id" => @income.id
    }
  end

  # destroying the clubs & users objects after tests run
  after(:all) do
    Club.destroy_all
    User.destroy_all
    Income.destroy_all
    User.destroy_all
    Level.destroy_all
  end

  # this action is in the devise_token_auth registrations controller
  describe "#create" do
    it "create a user but not send back token b/c user has to be confirmed with email address" do
      post = post '/auth', @user_create_hash
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)["status"]).to eq("success")
      expect(JSON.parse(response.body)["data"]["id"]).to eq(User.last.id)
    end
  end
end
