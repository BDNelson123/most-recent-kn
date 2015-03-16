require 'spec_helper'

describe V1::PackagesController do
  before(:all) do
    @package1 = FactoryGirl.create(:package, :name => "Bronze", :description => nil, :features => ["FlyingTee Membership card", "20 credits"], :price => "22.0")
    @package2 = FactoryGirl.create(:package, :name => "Silver", :description => nil, :features => ["FlyingTee Membership card", "60 credits", "2 free premium club set rentals"], :price => "50.0")
    @package3 = FactoryGirl.create(:package, :name => "Gold", :description => nil, :features => ["FlyingTee Membership card", "120 credits", "5 free premium club set rentals", "10% off food and beverage"], :price => "100.0")
  end

  after(:all) do
    Package.destroy_all
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
      expect(JSON.parse(response.body)[1]['name'].to_s).to eq(@package2.name.to_s)
      expect(JSON.parse(response.body)[2]['name'].to_s).to eq(@package3.name.to_s)
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
      expect(JSON.parse(response.body)['features'].to_s).to eq(@package1.features.to_s)
      expect(JSON.parse(response.body)['price'].to_s).to eq(@package1.price.to_s)
    end

    it "should return the correct data for package2" do
      get :show, { 'id' => @package2.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@package2.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@package2.name.to_s)
      expect(JSON.parse(response.body)['description'].to_s).to eq(@package2.description.to_s)
      expect(JSON.parse(response.body)['features'].to_s).to eq(@package2.features.to_s)
      expect(JSON.parse(response.body)['price'].to_s).to eq(@package2.price.to_s)
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
