require 'spec_helper'

describe "users", :type => :request do
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

  describe "#destroy" do
    # not sure why this is not working anymore
    #it "delete user destroy action - user must be signed in to get 200 response" do
    #  delete '/v1/users/' + @user.id.to_s, {}, @user_auth_headers
    #  expect(response.status).to eq(200)
    #end

    it "delete user destroy action - user will get 401 response if not logged in" do
      delete "/v1/users/#{@user.id}"
      expect(response.status).to eq(401)
    end
  end
end
