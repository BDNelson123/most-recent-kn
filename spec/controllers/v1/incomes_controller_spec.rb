require 'spec_helper'

describe V1::IncomesController do
  before(:all) do
    @income1 = FactoryGirl.create(:income, :name => "Under $20,000")
    @income2 = FactoryGirl.create(:income, :name => "$20,000 - $40,000")
    @income3 = FactoryGirl.create(:income, :name => "$40,000 - $60,000")
  end

  after(:all) do
    Income.destroy_all
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
      expect(JSON.parse(response.body)[0]['name'].to_s).to eq(@income1.name.to_s)
      expect(JSON.parse(response.body)[1]['name'].to_s).to eq(@income2.name.to_s)
      expect(JSON.parse(response.body)[2]['name'].to_s).to eq(@income3.name.to_s)
    end
  end

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @income1.id }
      expect(response.status).to eq(200)
    end

    it "should return 1 record" do
      get :show, { 'id' => @income1.id }
      expect(JSON.parse(response.body).length).to eq(2) # 2 fields for one record (id and name)
    end

    it "should return the correct data for income1" do
      get :show, { 'id' => @income1.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@income1.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@income1.name.to_s)
    end

    it "should return the correct data for income2" do
      get :show, { 'id' => @income2.id }
      expect(JSON.parse(response.body)['id'].to_i).to eq(@income2.id.to_i)
      expect(JSON.parse(response.body)['name'].to_s).to eq(@income2.name.to_s)
    end

    it "should return the correct error if the income id can't be found" do
      get :show, { 'id' => @income3.id + 1 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The income with id #{@income3.id + 1} could not be found.")
    end

    it "should return the correct status if the income id can't be found" do
      get :show, { 'id' => @income3.id + 1 }
      expect(response.status).to eq(422)
    end
  end
end
