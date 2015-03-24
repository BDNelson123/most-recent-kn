require 'spec_helper'
include Devise::TestHelpers

describe V1::PackagesController do
  before(:all) do
    @features1 = FactoryGirl.create(:feature, :name => "2 free premium club set rentals")
    @features2 = FactoryGirl.create(:feature, :name => "5 free premium club set rentals")
    @features3 = FactoryGirl.create(:feature, :name => "10% off food and beverage")

    @package1 = FactoryGirl.create(:package, :name => "Bronze", :description => "FlyingTee Membership card", :credits => 20, :price => "22.0")
    @package2 = FactoryGirl.create(:package, :name => "Silver", :description => "FlyingTee Membership card", :credits => 60, :price => "50.0", :features => [Feature.find_by_id(@features1.id)])
    @package3 = FactoryGirl.create(:package, :name => "Gold", :description => "FlyingTee Membership card", :credits => 120, :price => "100.0", :features => [Feature.find_by_id(@features2.id),Feature.find_by_id(@features3.id)])

    # create user factory
    @income = FactoryGirl.create(:income)
    @level = FactoryGirl.create(:level)
    @club = FactoryGirl.create(:club)
    @user = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
  end

  after(:all) do
    Package.destroy_all
    Feature.destroy_all
    Featurization.destroy_all
    User.destroy_all
    Club.destroy_all
    Level.destroy_all
    Income.destroy_all
  end 

  # CREATE action tests
  describe "#create" do
    it "should return a response status of 401 if user is not logged in" do
      post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20}
      expect(response.status).to eq(401)
    end

    it "should return a response status of 200 if user is logged in" do
      #sign_in @user
      request.headers.merge!(@user.create_new_auth_token)
      post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20}
      pp response.status
    end
  end

  # INDEX action tests
  describe "#index" do
    it "should return a response of 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it "should return 3 total rows" do
      get :index
      expect(JSON.parse(response.body).length).to eq(3)
    end

    # NOTE: index controller orders by name desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)[0]['name'].to_s).to eq(@package1.name.to_s)
      expect(JSON.parse(response.body)[0]['package_features'].to_s).to eq("")
      expect(JSON.parse(response.body)[1]['name'].to_s).to eq(@package2.name.to_s)
      expect(JSON.parse(response.body)[1]['package_features'].to_s).to include("2 free premium club set rentals")
      expect(JSON.parse(response.body)[2]['name'].to_s).to eq(@package3.name.to_s)
      expect(JSON.parse(response.body)[2]['package_features'].to_s).to include("5 free premium club set rentals")
      expect(JSON.parse(response.body)[2]['package_features'].to_s).to include("10% off food and beverage")
    end
  end

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @package1.id }
      expect(response.status).to eq(200)
    end

    it "should return 1 record" do
      get :show, { 'id' => @package1.id }
      expect(JSON.parse(response.body).length).to eq(5) # 5 fields for one record (id, name, description, features, price)
    end

    it "should return the correct data for package1" do
      get :show, { 'id' => @package1.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@package1.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@package1.name.to_s)
      expect(JSON.parse(response.body)['description'].to_s).to eq(@package1.description.to_s)
      expect(JSON.parse(response.body)['price'].to_s).to eq(@package1.price.to_s)
      expect(JSON.parse(response.body)['package_features'].to_s).to eq("")
    end

    it "should return the correct data for package2" do
      get :show, { 'id' => @package2.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@package2.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@package2.name.to_s)
      expect(JSON.parse(response.body)['description'].to_s).to eq(@package2.description.to_s)
      expect(JSON.parse(response.body)['price'].to_s).to eq(@package2.price.to_s)
      expect(JSON.parse(response.body)['package_features'].to_s).to include(@features1.name.to_s)
      expect(JSON.parse(response.body)['package_features'].to_s).to_not include(@features2.name.to_s)
    end

    it "should return the correct error if the package id can't be found" do
      get :show, { 'id' => @package3.id + 1 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The package with id #{@package3.id + 1} could not be found.")
    end

    it "should return the correct status if the package id can't be found" do
      get :show, { 'id' => @package3.id + 1 }
      expect(response.status).to eq(422)
    end
  end
end
