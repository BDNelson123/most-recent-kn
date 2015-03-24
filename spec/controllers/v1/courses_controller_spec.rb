require 'spec_helper'
include SpecHelpers

describe V1::CoursesController, :type => :api do
  before(:all) do
    @course1 = FactoryGirl.create(:course, :name => "Cameron Park Country Club")
    @course2 = FactoryGirl.create(:course, :name => "La Quinta Country Club", :address => "77-750 50th Ave", :address2 => "", :city => "La Quinta", :state => "CA", :zip => "92253")
    @course3 = FactoryGirl.create(:course, :name => "Ponderosa Golf Course", :address => "10040 Reynolds Way", :address2 => "", :city => "Truckee", :state => "CA", :zip => "96160")
  end

  after(:all) do
    delete_factories
  end

  # INDEX action tests
  describe "#index" do
    it "should return a response of 200" do
      get :index
      expect(response.status).to eq(200)
    end

    it "should return 3 total rows" do
      get :index
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end

    # NOTE: index controller orders by name desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@course1.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@course2.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@course3.name.to_s)
    end
  end

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @course1.id }
      expect(response.status).to eq(200)
    end

    it "should return 1 record" do
      get :show, { 'id' => @course1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(7) # 7 fields for one record (id, name, address, address2, city, state, zip)
    end

    it "should return the correct data for course1" do
      get :show, { 'id' => @course1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@course1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@course1.name.to_s)
      expect(JSON.parse(response.body)['data']['address'].to_s).to eq(@course1.address.to_s)
      expect(JSON.parse(response.body)['data']['address2'].to_s).to eq(@course1.address2.to_s)
      expect(JSON.parse(response.body)['data']['city'].to_s).to eq(@course1.city.to_s)
      expect(JSON.parse(response.body)['data']['state'].to_s).to eq(@course1.state.to_s)
      expect(JSON.parse(response.body)['data']['zip'].to_i).to eq(@course1.zip.to_i)
    end

    it "should return the correct data for course2" do
      get :show, { 'id' => @course2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@course2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@course2.name.to_s)
      expect(JSON.parse(response.body)['data']['address'].to_s).to eq(@course2.address.to_s)
      expect(JSON.parse(response.body)['data']['address2'].to_s).to eq(@course2.address2.to_s)
      expect(JSON.parse(response.body)['data']['city'].to_s).to eq(@course2.city.to_s)
      expect(JSON.parse(response.body)['data']['state'].to_s).to eq(@course2.state.to_s)
      expect(JSON.parse(response.body)['data']['zip'].to_i).to eq(@course2.zip.to_i)
    end

    it "should return the correct error if the course id can't be found" do
      get :show, { 'id' => @course3.id + 1 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The course with id #{@course3.id + 1} could not be found.")
    end

    it "should return the correct status if the course id can't be found" do
      get :show, { 'id' => @course3.id + 1 }
      expect(response.status).to eq(422)
    end
  end
end
