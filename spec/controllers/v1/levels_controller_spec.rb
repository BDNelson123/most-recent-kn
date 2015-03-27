require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::LevelsController do
  before(:all) do
    delete_factories
    create_user # move create_user to before level factories to make index tests work

    @level1 = FactoryGirl.create(:level)
    @level2 = FactoryGirl.create(:level)
    @level3 = FactoryGirl.create(:level)
    @level4 = FactoryGirl.create(:level)
    @level5 = FactoryGirl.create(:level)
  end

  after(:all) do
    delete_factories
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # CREATE action tests
  describe "#create" do
    context "authentication" do
      it "should return a response status of 401 if user is not logged in" do
        post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => "test"}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 201 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => "test"}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response status" do
      context "validations" do
        it "should return a response status of 422 if record is not created - name not present" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          post :create, format: :json, :level => {:name => nil, :description => "test", :handicap => "test"}
          expect(response.status).to eq(422)
        end

        # --------------- #

        it "should return a response status of 422 if record is not created - description not present" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          post :create, format: :json, :level => {:name => "test", :description => nil, :handicap => "test"}
          expect(response.status).to eq(422)
        end

        # --------------- #

        it "should return a response status of 422 if record is not created - handicap not present" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => nil}
          expect(response.status).to eq(422)
        end

        # --------------- #

        it "should return a response status of 422 if record already exists - validation for unique name" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)

          level6 = FactoryGirl.create(:level, :name => "test")
          post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => "test"}
          expect(response.status).to eq(422)
          level6.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "level record creation" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => "test"}}.to change(Level, :count).by(1)
      end

      # --------------- #

      it "should not add new record to db - not signed in" do
        expect {post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => "test"}}.to change(Level, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - nil" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :level => {:name => nil, :description => "test", :handicap => "test"}}.to change(Level, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for handicap - nil" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :level => {:name => "test", :description => "test", :handicap => nil}}.to change(Level, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for description - nil" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :level => {:name => "test", :description => nil, :handicap => "test"}}.to change(Level, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - not unique" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :level => {:name => @level1.name.to_s, :description => "test", :handicap => "test"}}.to change(Level, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "returned data" do
      it "should return the object id and name in the data hash" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :level => {:name => "test name", :description => "test description", :handicap => "test handicap"}
        expect(JSON.parse(response.body)['data'].to_s).to include("test name")
        expect(JSON.parse(response.body)['data'].to_s).to include("test description")
        expect(JSON.parse(response.body)['data'].to_s).to include("test handicap")
      end

      # --------------- #

      it "should return the validation error for name already being taken" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :level => {:name => @level1.name.to_s, :description => "test description", :handicap => "test handicap"}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :level => {:name => nil, :description => "test description", :handicap => "test handicap"}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
      end

      # --------------- #

      it "should return the validation error for description being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :level => {:name => "test name", :description => nil, :handicap => "test handicap"}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Description can't be blank")
      end

      # --------------- #

      it "should return the validation error for handicap being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :level => {:name => "test name", :description => "test description", :handicap => nil}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Handicap can't be blank")
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # INDEX action tests
  describe "#index" do
    it "should return a response of 200" do
      get :index
      expect(response.status).to eq(200)
    end

    # --------------- #

    it "should return 5 total rows" do
      #NOTE: 6 comes from user model needing to create a level
      get :index
      expect(JSON.parse(response.body)['data'].length).to eq(6)
    end

    # --------------- #

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

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @level1.id }
      expect(response.status).to eq(200)
    end

    # --------------- #

    it "should return 1 record" do
      get :show, { 'id' => @level1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(4) # 4 fields for one record (id, name, handicap, description,)
    end

    # --------------- #

    it "should return the correct data for level1" do
      get :show, { 'id' => @level1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@level1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@level1.name.to_s)
      expect(JSON.parse(response.body)['data']['handicap'].to_s).to eq(@level1.handicap.to_s)
      expect(JSON.parse(response.body)['data']['description'].to_s).to eq(@level1.description.to_s)
    end

    # --------------- #

    it "should return the correct data for level2" do
      get :show, { 'id' => @level2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@level2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@level2.name.to_s)
      expect(JSON.parse(response.body)['data']['handicap'].to_s).to eq(@level2.handicap.to_s)
      expect(JSON.parse(response.body)['data']['description'].to_s).to eq(@level2.description.to_s)
    end

    # --------------- #

    it "should return the correct error if the level id can't be found" do
      #NOTE: + 2 comes from user model needing to create a level
      level4 = Level.last
      get :show, { 'id' => level4.id + 2 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The level with id #{level4.id + 2} could not be found.")
    end

    # --------------- #

    it "should return the correct status if the level id can't be found" do
      #NOTE: + 2 comes from user model needing to create a level
      level4 = Level.last
      get :show, { 'id' => level4.id + 2 }
      expect(response.status).to eq(422)
    end
  end
end
