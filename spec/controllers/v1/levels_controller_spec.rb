require 'spec_helper'
include SpecHelpers

describe V1::LevelsController do
  before(:all) do
    @level1 = FactoryGirl.create(:level, :name => "Touring Pro", :handicap => "0-5 Handicap", :description => "Scratch Golfer")
    @level2 = FactoryGirl.create(:level, :name => "Varsity", :handicap => "6-10 Handicap", :description => "Plays frequently")
    @level3 = FactoryGirl.create(:level, :name => "Junior Varsity", :handicap => "11-20 Handicap", :description => "Plays frequently during the season")
    @level4 = FactoryGirl.create(:level, :name => "Casual", :handicap => "20+ Handicap", :description => "Plays a couple of times per year")
    @level5 = FactoryGirl.create(:level, :name => "Junior", :handicap => "No Handicap", :description => "Rarely Plays")
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

    it "should return 5 total rows" do
      get :index
      expect(JSON.parse(response.body)['data'].length).to eq(5)
    end

    # NOTE: index controller orders by id desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][4]['name'].to_s).to eq(@level1.name.to_s)
      expect(JSON.parse(response.body)['data'][4]['handicap'].to_s).to eq(@level1.handicap.to_s)
      expect(JSON.parse(response.body)['data'][4]['description'].to_s).to eq(@level1.description.to_s)

      expect(JSON.parse(response.body)['data'][3]['name'].to_s).to eq(@level2.name.to_s)
      expect(JSON.parse(response.body)['data'][3]['handicap'].to_s).to eq(@level2.handicap.to_s)
      expect(JSON.parse(response.body)['data'][3]['description'].to_s).to eq(@level2.description.to_s)

      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@level3.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['handicap'].to_s).to eq(@level3.handicap.to_s)
      expect(JSON.parse(response.body)['data'][2]['description'].to_s).to eq(@level3.description.to_s)

      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@level4.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['handicap'].to_s).to eq(@level4.handicap.to_s)
      expect(JSON.parse(response.body)['data'][1]['description'].to_s).to eq(@level4.description.to_s)

      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@level5.name.to_s)
      expect(JSON.parse(response.body)['data'][0]['handicap'].to_s).to eq(@level5.handicap.to_s)
      expect(JSON.parse(response.body)['data'][0]['description'].to_s).to eq(@level5.description.to_s)
    end
  end

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @level1.id }
      expect(response.status).to eq(200)
    end

    it "should return 1 record" do
      get :show, { 'id' => @level1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(4) # 4 fields for one record (id, name, handicap, description,)
    end

    it "should return the correct data for level1" do
      get :show, { 'id' => @level1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@level1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@level1.name.to_s)
      expect(JSON.parse(response.body)['data']['handicap'].to_s).to eq(@level1.handicap.to_s)
      expect(JSON.parse(response.body)['data']['description'].to_s).to eq(@level1.description.to_s)
    end

    it "should return the correct data for level2" do
      get :show, { 'id' => @level2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@level2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@level2.name.to_s)
      expect(JSON.parse(response.body)['data']['handicap'].to_s).to eq(@level2.handicap.to_s)
      expect(JSON.parse(response.body)['data']['description'].to_s).to eq(@level2.description.to_s)
    end

    it "should return the correct error if the level id can't be found" do
      level4 = Level.last
      get :show, { 'id' => level4.id + 1 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The level with id #{level4.id + 1} could not be found.")
    end

    it "should return the correct status if the level id can't be found" do
      level4 = Level.last
      get :show, { 'id' => level4.id + 1 }
      expect(response.status).to eq(422)
    end
  end
end
