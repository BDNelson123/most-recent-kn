require 'spec_helper'

describe "user authentication", :type => :request do
  before(:all) do
    # building the club objects needed for testing
    @club1 = FactoryGirl.create(:club)
    @club2 = FactoryGirl.create(:club, :name => "Adams Golf")

    # user created so we can test API calls
    @user = User.new(
      "name" => Faker::Name.name, "address" => Faker::Address.street_address, "address2" => Faker::Address.secondary_address, 
      "city" => Faker::Address.city, "state" => Faker::Address.state_abbr, "zip" => Faker::Address.zip,
      "phone" => "18067770259", "dob" => "1-1-1985", "handedness" => false,
      "owns_clubs" => false, "iron_club_id" => @club1.id, "wood_club_id" => @club2.id,
      "gender" => false, "email" => Faker::Internet.email, "password" => "test1234", "password_confirmation" => "test1234",
      "provider" => "email", "uid" => SecureRandom.uuid
    )
    @user.skip_confirmation!
    @user.save!

    # header with token, client, and expiry in it
    @user_auth_headers = @user.create_new_auth_token
    @user_token     = @user_auth_headers['access-token']
    @user_client_id = @user_auth_headers['client']
    @user_expiry    = @user_auth_headers['expiry']
  end

  # destroying the clubs & users objects after tests run
  after(:all) do
    Club.destroy_all
    User.destroy_all
  end

  # this action is in the devise_token_auth registrations controller
  describe "#create" do
    it "create a user but not send back token b/c user has to be confirmed with email address" do
      post = post '/auth', { 
        "name" => Faker::Name.name, "address" => Faker::Address.street_address, "address2" => Faker::Address.secondary_address, 
        "city" => Faker::Address.city, "state" => Faker::Address.state_abbr, "zip" => Faker::Address.zip,
        "phone" => "18067770259", "dob" => "1-1-1985", "handedness" => false,
        "owns_clubs" => false, "iron_club_id" => @club1.id, "wood_club_id" => @club2.id,
        "gender" => false, "email" => Faker::Internet.email, "password" => "test1234", "password_confirmation" => "test1234", 
        "confirm_success_url" => true
      }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)["status"]).to eq("success")
      expect(JSON.parse(response.body)["data"]["id"]).to eq(User.last.id)
    end
  end
end
