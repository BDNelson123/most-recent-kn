require 'spec_helper'

describe V1::ClubsController, :type => :api do
  before(:all) do
    @club1 = FactoryGirl.create(:club, :name => "Callaway Golf")
    @club2 = FactoryGirl.create(:club, :name => "Ben Hogan")
    @club3 = FactoryGirl.create(:club, :name => "Bridgestone")
  end

  after(:all) do
    Club.destroy_all
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
      expect(JSON.parse(response.body)[0]['name'].to_s).to eq(@club2.name.to_s)
      expect(JSON.parse(response.body)[1]['name'].to_s).to eq(@club3.name.to_s)
      expect(JSON.parse(response.body)[2]['name'].to_s).to eq(@club1.name.to_s)
    end
  end

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @club1.id }
      expect(response.status).to eq(200)
    end

    it "should return 1 record" do
      get :show, { 'id' => @club1.id }
      expect(JSON.parse(response.body).length).to eq(2) # 2 fields for one record (id and name)
    end

    it "should return the correct data for club1" do
      get :show, { 'id' => @club1.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@club1.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@club1.name.to_s)
    end

    it "should return the correct data for club2" do
      get :show, { 'id' => @club2.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@club2.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@club2.name.to_s)
    end

    it "should return the correct error if the club id can't be found" do
      get :show, { 'id' => @club3.id + 1 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The club with id #{@club3.id + 1} could not be found.")
    end

    it "should return the correct status if the club id can't be found" do
      get :show, { 'id' => @club3.id + 1 }
      expect(response.status).to eq(422)
    end
  end
end
