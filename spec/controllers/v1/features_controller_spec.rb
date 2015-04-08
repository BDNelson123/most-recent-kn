require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::FeaturesController, :type => :api do
  before(:all) do
    @feature1 = FactoryGirl.create(:feature)
    @feature2 = FactoryGirl.create(:feature)
    @feature3 = FactoryGirl.create(:feature)
    create_user_employee_admin
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
      it "should return a response status of 401 if no one is not logged in" do
        post :create, format: :json, :feature => {:name => "test"}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if user is logged in" do
        custom_sign_in @user
        post :create, format: :json, :feature => {:name => "test"}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if employee is logged in" do
        custom_sign_in @employee
        post :create, format: :json, :feature => {:name => "test"}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 201 if user is logged in" do
        custom_sign_in @admin
        post :create, format: :json, :feature => {:name => "test"}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response status" do
      it "should return a response status of 422 if record is not created" do
        custom_sign_in @admin
        post :create, format: :json, :feature => {:name => nil}
        expect(response.status).to eq(422)
      end

      it "should return a response status of 422 if record already exists - validation for unique name" do
        custom_sign_in @admin
        feature4 = FactoryGirl.create(:feature, :name => "test")
        post :create, format: :json, :feature => {:name => "test"}
        expect(response.status).to eq(422)
        feature4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "feature record creation" do
      it "should add new record to db" do
        custom_sign_in @admin
        expect {post :create, format: :json, :feature => {:name => "test"}}.to change(Feature, :count).by(1)
      end

      # --------------- #

      it "should not add new record to db - not signed in" do
        expect {post :create, format: :json, :feature => {:name => "test"}}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - user signed in" do
        custom_sign_in @user
        expect {post :create, format: :json, :feature => {:name => "test"}}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - employee signed in" do
        custom_sign_in @employee
        expect {post :create, format: :json, :feature => {:name => "test"}}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - nil" do
        custom_sign_in @admin
        expect {post :create, format: :json, :feature => {:name => nil}}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - not unique" do
        custom_sign_in @admin
        expect {post :create, format: :json, :feature => {:name => @feature1.name.to_s}}.to change(Feature, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "returned data" do
      it "should return the object id and name in the data hash" do
        custom_sign_in @admin
        post :create, format: :json, :feature => {:name => "thisisasuperdupertest"}
        expect(JSON.parse(response.body)['data'].to_s).to include("\"name\"=>\"thisisasuperdupertest\"")
      end

      # --------------- #

      it "should return the validation error for name already being taken" do
        custom_sign_in @admin
        post :create, format: :json, :feature => {:name => @feature1.name.to_s}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        custom_sign_in @admin
        post :create, format: :json, :feature => {:name => nil}
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
      @feature4 = FactoryGirl.create(:feature)
      @package1 = FactoryGirl.create(:package)
      @featurization1 = FactoryGirl.create(:featurization, :feature_id => @feature4.id, :package_id => @package1.id)
    end

    after(:each) do
      @feature4.destroy
      @package1.destroy
      @featurization1.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response status" do
      it "should return a response status of 401 if no one is not logged in" do
        delete :destroy, format: :json, :id => @feature4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if user is logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @feature4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if employee is logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @feature4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 202 if user is logged in" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @feature4.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "feature record deletion" do
      it "should delete record from feature table" do
        custom_sign_in @admin
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Feature, :count).by(-1)
      end

      # --------------- #

      it "should not delete record from features table - not signed in" do
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not delete record from features table - user signed in" do
        custom_sign_in @user
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not delete record from features table - employee signed in" do
        custom_sign_in @employee
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Feature, :count).by(0)
      end

      # --------------- #

      it "should not delete record from featurizations table - not signed in" do
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Featurization, :count).by(0)
      end

      # --------------- #

      it "should not delete record from featurizations table - user signed in" do
        custom_sign_in @user
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Featurization, :count).by(0)
      end

      # --------------- #

      it "should not delete record from featurizations table - employee signed in" do
        custom_sign_in @employee
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Featurization, :count).by(0)
      end

      # --------------- #

      it "should delete record from featurizations table" do
        custom_sign_in @admin
        expect {delete :destroy, format: :json, :id => @feature4.id}.to change(Featurization, :count).by(-1)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @feature4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that user is not authorized - user logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @feature4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that user is not authorized - employee logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @feature4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @feature4.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The feature with id #{@feature4.id} has been deleted.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @feature4.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The feature with id #{@feature4.id + 1} could not be found.")
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
      #NOTE: reason for 4 is that when we mock a user, we have to mock a feature object for it
        # so we will return @feature1, @feature2, @feature3, and the feature in SpecHelpers create_user
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end

    # --------------- #

    # NOTE: index controller orders by name desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'].to_s).to include(@feature1.name.to_s)
      expect(JSON.parse(response.body)['data'].to_s).to include(@feature2.name.to_s)
      expect(JSON.parse(response.body)['data'].to_s).to include(@feature3.name.to_s)
    end

    # ------------------------------ #
    # ------------------------------ #

    context "where_attributes" do
      it "should return 2 results where id > @feature1.id" do
        get :index, format: :json, :where => "id > #{@feature1.id}"
        expect(JSON.parse(response.body)['data'].length).to eq(2)
      end

      # --------------- #

      it "should return 1 result where name = @feature1.name" do
        get :index, format: :json, :where => "name='#{@feature1.name.to_s}'"
        expect(JSON.parse(response.body)['data'].length).to eq(1)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@feature1.name.to_s)
      end

      # --------------- #

      it "should not return an error if the query is valid but no results were returned" do
        get :index, format: :json, :where => "name='this wont give any result'"
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return an error if the query is invalid" do
        get :index, format: :json, :where => "testtesttest='#{@feature1.name.to_s}'"
        expect(JSON.parse(response.body)['errors']).to eq("Your query is invalid.")
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "count" do
      it "should return 3 results" do
        get :index, format: :json, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(3)
      end

      # --------------- #

      it "should return 1 result with a where statement of id > @feature2.id" do
        get :index, format: :json, :count => "true", :where => "id>'#{@feature2.id}'"
        expect(JSON.parse(response.body)['data']['count']).to eq(1)
      end

      # --------------- #

      it "should return 0 results if the query is valid but no results were returned" do
        get :index, format: :json, :count => "true", :where => "name='this wont give any result'"
        expect(JSON.parse(response.body)['data']['count']).to eq(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "search" do
      it "should return 1 result" do
        get :index, format: :json, :search => @feature1.name
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :where => "id>'#{@feature1.id}'", :search => @feature2.name
        expect(JSON.parse(response.body)['data'].length).to be >= 1
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@feature2.name)
      end

      # --------------- #

      it "should return 0 results" do
        get :index, format: :json, :where => "id>'#{@feature1.id}'", :search => @feature1.name
        expect(JSON.parse(response.body)['data']).to_not include(@feature1.name.to_s)
      end

      # --------------- #

      it "should return a value of 1 when user searches for @feature1.name and wants to count it" do
        get :index, format: :json, :search => @feature1.name, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 1 when user searches for @feature1.name and wants to count it with a where statement" do
        get :index, format: :json, :where => "id>'#{@feature1.id}'", :search => @feature2.name, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 2 when user searches for @feature1.name and wants to count it with a where statement - new record used" do
        feature4 = FactoryGirl.create(:feature, :name => @feature2.name + "2")
        get :index, format: :json, :where => "id>'#{@feature1.id}'", :search => @feature2.name, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(2)
      end

      # --------------- #

      it "should return the correct values when searching with where statement" do
        feature4 = FactoryGirl.create(:feature, :name => @feature2.name + "2")
        get :index, format: :json, :where => "id>'#{@feature1.id}'", :search => @feature2.name
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@feature2.name)
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(@feature2.name + "2")
      end
    end

    #NOTE: there are 29 results - 26 from alphabet, 3 from before_all
    context "pagination" do
      context "page" do
        before(:all) do
          ("a".."z").each do |u|
            FactoryGirl.create(:feature, :name => u)
          end
        end

        after(:all) do
          ("a".."z").each do |u|
            Feature.where(:name => u).destroy_all
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "results length" do
          it "should return 15 results for the first page" do
            custom_sign_in @admin
            get :index, format: :json, :page => 1
            expect(JSON.parse(response.body)['data'].length).to eq(15)
          end

          # --------------- #

          it "should return 14 results for the second page" do
            custom_sign_in @admin
            get :index, format: :json, :page => 2
            expect(JSON.parse(response.body)['data'].length).to eq(14)
          end

          # --------------- #

          it "should return 0 results for the third page" do
            custom_sign_in @admin
            get :index, format: :json, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(0)
          end

          # --------------- #

          it "should return 10 results for the first page with per_page param" do
            custom_sign_in @admin
            get :index, format: :json, :per_page => 10
            expect(JSON.parse(response.body)['data'].length).to eq(10)
          end

          # --------------- #

          it "should return 9 results for the third page with per_page param" do
            custom_sign_in @admin
            get :index, format: :json, :per_page => 10, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(9)
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "order by" do
          context "name" do
            it "should return user with name of 'a' for first result when ordering by name asc" do
              custom_sign_in @admin
              get :index, format: :json, :order_by => "name", :order_direction => "ASC"
              expect(JSON.parse(response.body)["data"][0]["name"].downcase).to start_with("a")
            end

            # --------------- #

            it "should return user with name of 'z' for first result when ordering by name desc" do
              custom_sign_in @admin
              get :index, format: :json, :order_by => "name", :order_direction => "DESC"
              expect(JSON.parse(response.body)["data"][0]["name"].downcase).to start_with("z")
            end
          end
        end
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # SHOW action tests
  describe "#show" do
    it "should return a response of 200" do
      get :show, { 'id' => @feature1.id }
      expect(response.status).to eq(200)
    end

    # --------------- #

    it "should return 1 record" do
      get :show, { 'id' => @feature1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(2) # 2 fields for one record (id and name)
    end

    # --------------- #

    it "should return the correct data for feature1" do
      get :show, { 'id' => @feature1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@feature1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@feature1.name.to_s)
    end

    # --------------- #

    it "should return the correct data for feature2" do
      get :show, { 'id' => @feature2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@feature2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@feature2.name.to_s)
    end

    # --------------- #

    it "should return the correct error if the feature id can't be found" do
      get :show, { 'id' => @feature3.id + 2 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The feature with id #{@feature3.id + 2} could not be found.")
    end

    # --------------- #

    it "should return the correct status if the feature id can't be found" do
      get :show, { 'id' => @feature3.id + 2 }
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
        it "should return a status of 422 if no one is not logged in" do
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(response.status).to eq(401)
          feature4.destroy
        end

        # --------------- #

        it "should return a status of 422 if user is logged in" do
          custom_sign_in @user
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(response.status).to eq(401)
          feature4.destroy
        end

        # --------------- #

        it "should return a status of 422 if employee is logged in" do
          custom_sign_in @employee
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(response.status).to eq(401)
          feature4.destroy
        end

        # --------------- #
        it "should return a status of 200 if admin is logged in" do
          custom_sign_in @admin
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(response.status).to eq(200)
          feature4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "no record" do
      it "should return a status of 422 if record cant be found" do
        custom_sign_in @admin
        #NOTE: this is due to the user model having a feature record (must add 2 - not 1)
        put :update, format: :json, :id => @feature3.id + 2, :feature => {:name => "test"}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return a status of 422 if feature name has already been taken" do
        custom_sign_in @admin
        feature4 = FactoryGirl.create(:feature)
        put :update, format: :json, :id => feature4.id, :feature => {:name => @feature1.name.to_s}
        expect(response.status).to eq(422)
        feature4.destroy
      end

      # --------------- #

      it "should return a status of 422 if feature name is blank" do
        custom_sign_in @admin
        feature4 = FactoryGirl.create(:feature)
        put :update, format: :json, :id => feature4.id, :feature => {:name => ""}
        expect(response.status).to eq(422)
        feature4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response data" do
      context "no record" do
        it "should return the correct error response if the feature id can't be found" do
          custom_sign_in @admin
          #NOTE: this is due to the user model having a feature record
          put :update, format: :json, :id => @feature3.id + 2, :feature => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to eq("The feature with id #{@feature3.id + 2} could not be found.")
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "authentication" do
        it "should return - Authorized users only. - if no one is not logged in" do
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          feature4.destroy
        end

        # --------------- #

        it "should return - Authorized users only. - if user is logged in" do
          custom_sign_in @user
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          feature4.destroy
        end

        # --------------- #

        it "should return - Authorized users only. - if employee is logged in" do
          custom_sign_in @employee
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          feature4.destroy
        end

        # --------------- #

        it "should return data of the updated feature if no validation errors and user logged in" do
          custom_sign_in @admin
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}
          expect(JSON.parse(response.body)['data']['name'].to_s).to eq("test")
          expect(JSON.parse(response.body)['data']['id'].to_s).to eq("#{feature4.id}")
          feature4.destroy
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "messages" do
        it "should return Name Can't be blank if name is blank" do
          custom_sign_in @admin
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => ""}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
          feature4.destroy
        end

        # --------------- #

        it "should return Name is already taken if name has already been taken" do
          custom_sign_in @admin
          feature4 = FactoryGirl.create(:feature)
          put :update, format: :json, :id => feature4.id, :feature => {:name => @feature1.name.to_s}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
          feature4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "db creation" do
      it "should not create or delete a record from the db when updating" do
        custom_sign_in @admin
        feature4 = FactoryGirl.create(:feature)
        expect {put :update, format: :json, :id => feature4.id, :feature => {:name => "test"}}.to change(Feature, :count).by(0)
        feature4.destroy
      end
    end
  end
end
