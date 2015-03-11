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

  # destroying the club objects after tests run
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

  # this action is in the users controller
  describe "#index" do
    it "get user index action - user must be signed in to get 200 response" do
      get '/v1/users', {}, @user_auth_headers
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)[0]["email"]).to eq(@user.email)
    end

    it "get user index action - user will get 401 response if not logged in" do
      get '/v1/users'
      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"errors"=>["Authorized users only."]})
    end
  end

  # this action is in the users controller
  describe "#show" do
    it "get user show action - user must be signed in to get 200 response" do
      get '/v1/users', { :id => @user.id }, @user_auth_headers
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)[0]["email"]).to eq(@user.email)
    end

    it "get user show action - user will get 401 response if not logged in" do
      get '/v1/users', { :id => @user.id }
      expect(response.status).to eq(401)
      expect(JSON.parse(response.body)).to eq({"errors"=>["Authorized users only."]})
    end
  end

  # this action is in the users controller
  describe "#destroy" do
    it "delete user destroy action - user must be signed in to get 200 response" do
      delete "/v1/users/#{@user.id}", {}, @user_auth_headers
      expect(response.status).to eq(200)
    end

    it "delete user destroy action - user will get 401 response if not logged in" do
      delete "/v1/users/#{@user.id}"
      expect(response.status).to eq(401)
    end
  end
end
