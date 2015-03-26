require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::ClubsController, :type => :api do
  before(:all) do
    @club1 = FactoryGirl.create(:club, :name => "Callaway Golf")
    @club2 = FactoryGirl.create(:club, :name => "Ben Hogan")
    @club3 = FactoryGirl.create(:club, :name => "Bridgestone")
    create_user
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
        post :create, format: :json, :club => {:name => "test"}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 201 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :club => {:name => "test"}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response status" do
      it "should return a response status of 422 if record is not created" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :club => {:name => nil}
        expect(response.status).to eq(422)
      end

      it "should return a response status of 422 if record already exists - validation for unique name" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        club4 = FactoryGirl.create(:club, :name => "test")
        post :create, format: :json, :club => {:name => "test"}
        expect(response.status).to eq(422)
        club4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "club record creation" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :club => {:name => "test"}}.to change(Club, :count).by(1)
      end

      # --------------- #

      it "should not add new record to db - not signed in" do
        expect {post :create, format: :json, :club => {:name => "test"}}.to change(Club, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - nil" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :club => {:name => nil}}.to change(Club, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - not unique" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :club => {:name => "Callaway Golf"}}.to change(Club, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "returned data" do
      it "should return the object id and name in the data hash" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :club => {:name => "thisisasuperdupertest"}
        expect(JSON.parse(response.body)['data'].to_s).to include("\"name\"=>\"thisisasuperdupertest\"")
      end

      # --------------- #

      it "should return the validation error for name already being taken" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :club => {:name => "Callaway Golf"}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :club => {:name => nil}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # DESTROY action tests
  describe "#destroy" do
    before(:each) do
      @club4 = FactoryGirl.create(:club, :name => "Yonex")
    end

    after(:each) do
      @club4.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response status" do
      it "should return a response status of 401 if user is not logged in" do
        delete :destroy, format: :json, :id => @club4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 202 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        delete :destroy, format: :json, :id => @club4.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "club record deletion" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {delete :destroy, format: :json, :id => @club4.id}.to change(Club, :count).by(-1)
      end

      # --------------- #

      it "should not delete record from db - not signed in" do
        expect {delete :destroy, format: :json, :id => @club4.id}.to change(Club, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @club4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @club4.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The club with id #{@club4.id} has been deleted.")
      end

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @club4.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The club with id #{@club4.id + 1} could not be found.")
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
      #NOTE: reason for 4 is that when we mock a user, we have to mock a club object for it
        # so we will return @club1, @club2, @club3, and the club in SpecHelpers create_user
      expect(JSON.parse(response.body)['data'].length).to eq(4)
    end

    # --------------- #

    # NOTE: index controller orders by name desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@club2.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@club3.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@club1.name.to_s)
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @club1.id }
      expect(response.status).to eq(200)
    end

    # --------------- #

    it "should return 1 record" do
      get :show, { 'id' => @club1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(2) # 2 fields for one record (id and name)
    end

    # --------------- #

    it "should return the correct data for club1" do
      get :show, { 'id' => @club1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@club1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@club1.name.to_s)
    end

    # --------------- #

    it "should return the correct data for club2" do
      get :show, { 'id' => @club2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@club2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@club2.name.to_s)
    end

    # --------------- #

    it "should return the correct error if the club id can't be found" do
      #NOTE: this is due to the user model having a club record
      get :show, { 'id' => @club3.id + 2 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The club with id #{@club3.id + 2} could not be found.")
    end

    # --------------- #

    it "should return the correct status if the club id can't be found" do
      #NOTE: this is due to the user model having a club record
      get :show, { 'id' => @club3.id + 2 }
      expect(response.status).to eq(422)
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # UPDATE action tests
  describe "#update" do
    context "response status" do
      context "authentication" do
        it "should return a status of 422 if user is not logged in" do
          club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
          put :update, format: :json, :id => club4.id, :club => {:name => "test"}
          expect(response.status).to eq(401)
          club4.destroy
        end

        # --------------- #

        it "should return a status of 200 if user is logged in" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
          put :update, format: :json, :id => club4.id, :club => {:name => "test"}
          expect(response.status).to eq(200)
          club4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "no record" do
      it "should return a status of 422 if record cant be found" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        #NOTE: this is due to the user model having a club record (must add 2 - not 1)
        put :update, format: :json, :id => @club3.id + 2, :club => {:name => "test"}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return a status of 422 if club name has already been taken" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
        put :update, format: :json, :id => club4.id, :club => {:name => "Callaway Golf"}
        expect(response.status).to eq(422)
        club4.destroy
      end

      # --------------- #

      it "should return a status of 422 if club name is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
        put :update, format: :json, :id => club4.id, :club => {:name => ""}
        expect(response.status).to eq(422)
        club4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response data" do
      context "no record" do
        it "should return the correct error response if the club id can't be found" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          #NOTE: this is due to the user model having a club record
          put :update, format: :json, :id => @club3.id + 2, :club => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to eq("The club with id #{@club3.id + 2} could not be found.")
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "authentication" do
        it "should return - Authorized users only. - if user is not logged in" do
          club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
          put :update, format: :json, :id => club4.id, :club => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          club4.destroy
        end

        # --------------- #

        it "should return data of the updated club if no validation errors and user logged in" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
          put :update, format: :json, :id => club4.id, :club => {:name => "test"}
          expect(JSON.parse(response.body)['data']['name'].to_s).to eq("test")
          expect(JSON.parse(response.body)['data']['id'].to_s).to eq("#{club4.id}")
          club4.destroy
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "messages" do
        it "should return Name Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
          put :update, format: :json, :id => club4.id, :club => {:name => ""}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
          club4.destroy
        end

        # --------------- #

        it "should return Name is already taken if name has already been taken" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
          put :update, format: :json, :id => club4.id, :club => {:name => "Callaway Golf"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
          club4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "db creation" do
      it "should not create or delete a record from the db when updating" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        club4 = FactoryGirl.create(:club, :name => "Cleveland Golf")
        expect {put :update, format: :json, :id => club4.id, :club => {:name => "test"}}.to change(Club, :count).by(0)
        club4.destroy
      end
    end
  end
end
