require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::PackagesController do
  before(:all) do
    @features1 = FactoryGirl.create(:feature, :name => "2 free premium club set rentals")
    @features2 = FactoryGirl.create(:feature, :name => "5 free premium club set rentals")
    @features3 = FactoryGirl.create(:feature, :name => "10% off food and beverage")

    @package1 = FactoryGirl.create(:package, :name => "Bronze", :description => "FlyingTee Membership card", :credits => 20, :price => "22.0")
    @package2 = FactoryGirl.create(:package, :name => "Silver", :description => "FlyingTee Membership card", :credits => 60, :price => "50.0", :features => [Feature.find_by_id(@features1.id)])
    @package3 = FactoryGirl.create(:package, :name => "Gold", :description => "FlyingTee Membership card", :credits => 120, :price => "100.0", :features => [Feature.find_by_id(@features2.id),Feature.find_by_id(@features3.id)])

    create_user
  end

  after(:all) do
    delete_factories
  end 

  # CREATE action tests
  describe "#create" do
    context "authentication" do
      it "should return a response status of 401 if user is not logged in" do
        post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features1.id}]}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 201 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, 
          format: :json, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id},{:feature_id => @features3.id}]}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response status" do
      it "should return a response status of 422 if record is not created" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, 
          format: :json, 
          :package => {:name => nil, :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id},{:feature_id => @features3.id}]}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "package record creation" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id},{:feature_id => @features3.id}]}}.to change(Package, :count).by(1)
      end

      # --------------- #

      it "should not add new record to db - not signed in" do
        expect {post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id},{:feature_id => @features3.id}]}}.to change(Package, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "featurization record creation" do
      it "should not add new record to db - not signed in" do
        expect {post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id},{:feature_id => @features3.id}]}}.to change(Featurization, :count).by(0)
      end

      # --------------- #

      it "should add one new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id}]}}.to change(Featurization, :count).by(1)
      end

      # --------------- #

      it "should add two new records to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id},{:feature_id => @features3.id}]}}.to change(Featurization, :count).by(2)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return 1 error for feature when its not a valid id" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json,  
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id + 1}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Featurizations feature must have a valid id")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for name when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json, 
          :package => {:name => "", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Name can't be blank")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for description when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json, 
          :package => {:name => "test", :description => "", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Description can't be blank")

        package4.destroy
      end

      it "should return 2 errors for price when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json, 
          :package => {:name => "test", :description => "test", :price => nil, :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Price can't be blank and Price is not a number")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for price when its not numeric" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json, 
          :package => {:name => "test", :description => "test", :price => "test", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Price is not a number")

        package4.destroy
      end

      # --------------- #

      it "should return 2 errors for credits when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => nil, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Credits can't be blank and Credits is not a number")
      end

      # --------------- #

      it "should return 1 error for credits when its not an integer" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        post :create, 
          format: :json, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => "test", :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Credits is not a number")

        package4.destroy
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # DESTROY action tests
  describe "#destroy" do
    before(:each) do
      @features4 = FactoryGirl.create(:feature, :name => "2 free tests")
      @features5 = FactoryGirl.create(:feature, :name => "5 free tests")
      @package4 = FactoryGirl.create(:package, 
        :name => "Platinum", 
        :description => "FlyingTee Membership card", 
        :credits => 500, 
        :price => "250.0", 
        :features => [Feature.find_by_id(@features4.id),Feature.find_by_id(@features5.id)]
      )
    end

    after(:each) do
      @features4.destroy
      @features5.destroy
      @package4.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response status" do
      it "should return a response status of 401 if user is not logged in" do
        delete :destroy, format: :json, :id => @package4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #
      it "should return a response status of 202 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        delete :destroy, format: :json, :id => @package4.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "package record deletion" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {delete :destroy, format: :json, :id => @package4.id}.to change(Package, :count).by(-1)
      end

      # --------------- #

      it "should not add new record to db - not signed in" do
        expect {delete :destroy, format: :json, :id => @package4.id}.to change(Package, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "featurization record deletion" do
      it "should not add new record to db - not signed in" do
        expect {delete :destroy, format: :json, :id => @package4.id}.to change(Featurization, :count).by(0)
      end

      # --------------- #

      it "should delete two records to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {delete :destroy, format: :json, :id => @package4.id}.to change(Featurization, :count).by(-2)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @package4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @package4.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The package with id #{@package4.id} has been deleted.")
      end

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @package4.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The package with id #{@package4.id + 1} could not be found.")
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

    it "should return 3 total rows" do
      get :index
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end

    # --------------- #

    # NOTE: index controller orders by name desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@package1.name.to_s)
      expect(JSON.parse(response.body)['data'][0]['package_features'].to_s).to eq("")
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@package2.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['package_features'].to_s).to include("2 free premium club set rentals")
      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@package3.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['package_features'].to_s).to include("5 free premium club set rentals")
      expect(JSON.parse(response.body)['data'][2]['package_features'].to_s).to include("10% off food and beverage")
    end
  end

  # SHOW action tests
  describe "#show" do
    context "response status" do 
      it "should return a response of 200 if record exists" do
        get :show, { 'id' => @package1.id }
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return a response of 422 if record does not exist" do
        get :show, { 'id' => @package3.id + 1 }
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    it "should return 1 record with 6 fields" do
      get :show, { 'id' => @package1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(6) # 6 fields for one record (id, name, description, features, price, credits)
    end

    # --------------- #

    it "should return the correct data for package1" do
      get :show, { 'id' => @package1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@package1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@package1.name.to_s)
      expect(JSON.parse(response.body)['data']['description'].to_s).to eq(@package1.description.to_s)
      expect(JSON.parse(response.body)['data']['price'].to_s).to eq(@package1.price.to_s)
      expect(JSON.parse(response.body)['data']['package_features'].to_s).to eq("")
    end

    # --------------- #

    it "should return the correct data for package2" do
      get :show, { 'id' => @package2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@package2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@package2.name.to_s)
      expect(JSON.parse(response.body)['data']['description'].to_s).to eq(@package2.description.to_s)
      expect(JSON.parse(response.body)['data']['price'].to_s).to eq(@package2.price.to_s)
      expect(JSON.parse(response.body)['data']['package_features'].to_s).to include(@features1.name.to_s)
      expect(JSON.parse(response.body)['data']['package_features'].to_s).to_not include(@features2.name.to_s)
    end

    # --------------- #

    it "should return the correct error if the package id can't be found" do
      get :show, { 'id' => @package3.id + 1 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The package with id #{@package3.id + 1} could not be found.")
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # UPDATE action tests
  describe "#update" do
    context "authentication and response status" do
      it "should return a status of 422 if user is not logged in" do
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{"feature_id" => @features1.id},{"feature_id" => @features2.id}]}
        expect(response.status).to eq(401)

        package4.destroy
      end

      # --------------- #

      it "should return a status of 200 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{"feature_id" => @features1.id},{"feature_id" => @features2.id}]}
        expect(response.status).to eq(200)

        package4.destroy
      end

      # --------------- #

      it "should return a status of 422 if record cant be found" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        put :update, 
          format: :json, 
          :id => @package3.id + 1, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{"feature_id" => @features1.id},{"feature_id" => @features2.id}]}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "featurization record creation / deletion" do
      it "should add one record to featurization db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        expect {put :update, format: :json, :id => package4.id, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, 
          :featurizations_attributes => [{"feature_id" => @features1.id},{"feature_id" => @features2.id}]}}.to change(Featurization, :count).by(1)

        package4.destroy
      end

      # --------------- #

      it "should add two records to featurization db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        expect {put :update, format: :json, :id => package4.id, :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, 
          :featurizations_attributes => [{"feature_id" => @features1.id},{"feature_id" => @features2.id},{"feature_id" => @features3.id}]}}.to change(Featurization, :count).by(2)

        package4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct data" do
      it "should return 6 fields" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{"feature_id" => @features1.id},{"feature_id" => @features2.id}]}
        expect(JSON.parse(response.body)['data'].length).to eq(6)

        package4.destroy
      end

      # --------------- #

      it "should return only the last two features and not the first one" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features2.id}, {:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['data']['package_features'].to_s).to include("5 free premium club set rentals")
        expect(JSON.parse(response.body)['data']['package_features'].to_s).to include("10% off food and beverage")
        expect(JSON.parse(response.body)['data']['package_features'].to_s).to_not include("2 free premium club set rentals")

        package4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return 1 error for feature when its not a valid id" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id + 1}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Featurizations feature must have a valid id")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for name when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "", :description => "test", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Name can't be blank")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for description when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "", :price => "22.0", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Description can't be blank")

        package4.destroy
      end

      # --------------- #

      it "should return 2 errors for price when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => nil, :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Price can't be blank and Price is not a number")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for price when its not numeric" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "test", :credits => 20, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Price is not a number")

        package4.destroy
      end

      # --------------- #

      it "should return 2 errors for credits when its blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => nil, :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Credits can't be blank and Credits is not a number")

        package4.destroy
      end

      # --------------- #

      it "should return 1 error for credits when its not an integer" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        package4 = FactoryGirl.create(:package, :name => "Platinum", :description => "FlyingTee Membership card", :credits => 500, :price => "250.0", :features => [Feature.find_by_id(@features1.id)])

        put :update, 
          format: :json, 
          :id => package4.id, 
          :package => {:name => "test", :description => "test", :price => "22.0", :credits => "test", :featurizations_attributes => [{:feature_id => @features3.id}]}
        expect(JSON.parse(response.body)['errors'].to_s).to eq("Credits is not a number")

        package4.destroy
      end
    end
  end
end
