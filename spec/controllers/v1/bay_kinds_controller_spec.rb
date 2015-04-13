require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::BayKindsController, :kind => :api do
  before(:all) do
    @bay_kind1 = FactoryGirl.create(:bay_kind)
    @bay_kind2 = FactoryGirl.create(:bay_kind)
    @bay_kind3 = FactoryGirl.create(:bay_kind)
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
      it "should return a response kind of 401 if no one is not logged in" do
        post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response kind of 401 if user is not logged in" do
        custom_sign_in @user
        post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response kind of 401 if employee is not logged in" do
        custom_sign_in @employee
        post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(401)
      end

      # --------------- #
      it "should return a response kind of 201 if admin is logged in" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response kind" do
      it "should return a response kind of 422 if record is not created - no name" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => nil, :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(422)
      end

      # --------------- #

      it "should return a response kind of 422 if record already exists - validation for unique name" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => @bay_kind1.name.to_s, :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(422)
      end

      # --------------- #

      it "should return a response kind of 422 if record already exists - no credits_per_hour" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => nil}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "bay_kind record creation" do
      it "should add new record to db" do
        custom_sign_in @admin
        expect {post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(1)
      end

      # --------------- #

      it "should not add new record to db - no one signed in" do
        expect {post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - user signed in" do
        custom_sign_in @user
        expect {post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - employee signed in" do
        custom_sign_in @employee
        expect {post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - nil" do
        custom_sign_in @admin
        expect {post :create, format: :json, :bay_kind => {:name => nil, :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for description - nil" do
        custom_sign_in @admin
        expect {post :create, format: :json, :bay_kind => {:name => "test name", :description => nil, :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for credits_per_hour - nil" do
        custom_sign_in @admin
        expect {post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => nil}}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - not unique" do
        custom_sign_in @admin
        expect {post :create, format: :json, :bay_kind => {:name => @bay_kind1.name.to_s, :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "returned data" do
      it "should return the object id and name in the data hash" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => "thisisasuperdupertest", :description => "test description", :credits_per_hour => 1}
        expect(JSON.parse(response.body)['data'].to_s).to include("\"name\"=>\"thisisasuperdupertest\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("\"description\"=>\"test description\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("1")
      end

      # --------------- #

      it "should return the validation error for name already being taken" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => @bay_kind1.name.to_s, :description => "test description", :credits_per_hour => 1}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => nil, :description => "test description", :credits_per_hour => 1}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => "test name", :description => nil, :credits_per_hour => 1}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Description can't be blank")
      end

      # --------------- #

      it "should return the validation error for credits_per_hour being null" do
        custom_sign_in @admin
        post :create, format: :json, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => nil}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Credits per hour can't be blank")
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # DESTROY action tests
  describe "#destroy" do
    before(:each) do
      @bay_kind4 = FactoryGirl.create(:bay_kind)
    end

    after(:each) do
      @bay_kind4.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response kind" do
      it "should return a response kind of 401 if no one is logged in" do
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response kind of 401 if user is logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response kind of 401 if employee is logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response kind of 202 if user is logged in" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "bay_kind record deletion" do
      it "should remove record from db" do
        custom_sign_in @admin
        expect {delete :destroy, format: :json, :id => @bay_kind4.id}.to change(BayKind, :count).by(-1)
      end

      # --------------- #

      it "should not delete record from db - no one signed in" do
        expect {delete :destroy, format: :json, :id => @bay_kind4.id}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not delete record from db - user signed in" do
        custom_sign_in @user
        expect {delete :destroy, format: :json, :id => @bay_kind4.id}.to change(BayKind, :count).by(0)
      end

      # --------------- #

      it "should not delete record from db - employee signed in" do
        custom_sign_in @employee
        expect {delete :destroy, format: :json, :id => @bay_kind4.id}.to change(BayKind, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that user is not authorized - user logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that user is not authorized - user logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @bay_kind4.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The bay kind with id #{@bay_kind4.id} has been deleted.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @bay_kind4.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The bay kind with id #{@bay_kind4.id + 1} could not be found.")
      end
    end
  end

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

    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@bay_kind1.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@bay_kind2.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@bay_kind3.name.to_s)
    end

    # ------------------------------ #
    # ------------------------------ #

    context "where_attributes" do
      it "should return 2 results where id > @bay_kind1.id" do
        get :index, format: :json, :where => "id > #{@bay_kind1.id}"
        expect(JSON.parse(response.body)['data'].length).to eq(2)
      end

      # --------------- #

      it "should return 1 result where name = @bay_kind1.name" do
        get :index, format: :json, :where => "name='#{@bay_kind1.name.to_s}'"
        expect(JSON.parse(response.body)['data'].length).to eq(1)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@bay_kind1.name.to_s)
      end

      # --------------- #

      it "should not return an error if the query is valid but no results were returned" do
        get :index, format: :json, :where => "name='this wont give any result'"
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return an error if the query is invalid" do
        get :index, format: :json, :where => "testtesttest='#{@bay_kind1.name.to_s}'"
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

      it "should return 1 result with a where statement of id > @bay_kind2.id" do
        get :index, format: :json, :count => "true", :where => "id>'#{@bay_kind2.id}'"
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
        get :index, format: :json, :search => @bay_kind1.name.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :where => "id>'#{@bay_kind1.id}'", :search => @bay_kind2.name.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@bay_kind2.name.to_s)
      end

      # --------------- #

      it "should return 0 results" do
        get :index, format: :json, :where => "id>'#{@bay_kind1.id}'", :search => @bay_kind1.name.to_s
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(JSON.parse(response.body)['data']).to_not include(@bay_kind1.name.to_s)
      end

      # --------------- #

      it "should return a value of 1 when user searches for @bay_kind1.name and wants to count it" do
        get :index, format: :json, :search => @bay_kind1.name.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 2 when user searches for @bay_kind1.name and wants to count it with a where statement - new record used" do
        bay_kind4 = FactoryGirl.create(:bay_kind, :name => @bay_kind2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@bay_kind1.id}'", :search => @bay_kind2.name.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(2)
        bay_kind4.destroy
      end

      # --------------- #

      it "should return the correct values when searching with where statement" do
        bay_kind4 = FactoryGirl.create(:bay_kind, :name => @bay_kind2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@bay_kind1.id}'", :search => @bay_kind2.name.to_s, :order_direction => "ASC"
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@bay_kind2.name.to_s)
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(bay_kind4.name.to_s)
        bay_kind4.destroy
      end

      # --------------- #

      it "should return the correct values when searching with where statement - order desc" do
        bay_kind4 = FactoryGirl.create(:bay_kind, :name => @bay_kind2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@bay_kind1.id}'", :search => @bay_kind2.name.to_s, :order_direction => "DESC"
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(@bay_kind2.name.to_s)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(bay_kind4.name.to_s)
        bay_kind4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    #NOTE: there are 29 results - 26 from alphabet, 3 from before_all
    context "pagination" do
      context "page" do
        before(:all) do
          ("a".."z").each do |u|
            FactoryGirl.create(:bay_kind, :name => u)
          end
        end

        after(:all) do
          ("a".."z").each do |u|
            BayKind.where(:name => u).destroy_all
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "results length" do
          it "should return 15 results for the first page" do
            get :index, format: :json, :page => 1
            expect(JSON.parse(response.body)['data'].length).to eq(15)
          end

          # --------------- #

          it "should return 6 results for the second page" do
            get :index, format: :json, :page => 2
            expect(JSON.parse(response.body)['data'].length).to eq(14)
          end

          # --------------- #

          it "should return 0 results for the third page" do
            get :index, format: :json, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(0)
          end

          # --------------- #

          it "should return 10 results for the first page with per_page param" do
            get :index, format: :json, :per_page => 10
            expect(JSON.parse(response.body)['data'].length).to eq(10)
          end

          # --------------- #

          it "should return 10 results for the third page with per_page param" do
            get :index, format: :json, :per_page => 10, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(9)
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "order by" do
          context "name" do
            it "should return user with name of 'a' for first result when ordering by name asc" do
              get :index, format: :json, :order_by => "name", :order_direction => "ASC"
              expect(JSON.parse(response.body)["data"][0]["name"].downcase).to start_with("a")
            end

            # --------------- #

            it "should return user with name of 'z' for first result when ordering by name desc" do
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
      get :show, { 'id' => @bay_kind1.id }
      expect(response.status).to eq(200)
    end

    # --------------- #

    it "should return 1 record" do
      get :show, { 'id' => @bay_kind1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(4) # 3 fields for one record (id, name, description, :credits_per_hour)
    end

    # --------------- #

    it "should return the correct data for bay_kind1" do
      get :show, { 'id' => @bay_kind1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@bay_kind1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@bay_kind1.name.to_s)
    end

    # --------------- #

    it "should return the correct data for bay_kind2" do
      get :show, { 'id' => @bay_kind2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@bay_kind2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@bay_kind2.name.to_s)
    end

    # --------------- #

    it "should return the correct error if the bay_kind id can't be found" do
      #NOTE: this is due to the user model having an bay_kind record
      get :show, { 'id' => @bay_kind3.id + 2 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The bay kind with id #{@bay_kind3.id + 2} could not be found.")
    end

    # --------------- #

    it "should return the correct kind if the bay_kind id can't be found" do
      #NOTE: this is due to the user model having an bay_kind record
      get :show, { 'id' => @bay_kind3.id + 2 }
      expect(response.status).to eq(422)
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # UPDATE action tests
  describe "#update" do
    context "response kind" do
      context "authentication" do
        it "should return a kind of 422 if no one logged in" do
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(response.status).to eq(401)
          bay_kind4.destroy
        end

        # --------------- #

        it "should return a kind of 422 if user is logged in" do
          custom_sign_in @user
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(response.status).to eq(401)
          bay_kind4.destroy
        end

        # --------------- #

        it "should return a kind of 422 if employee is logged in" do
          custom_sign_in @employee
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(response.status).to eq(401)
          bay_kind4.destroy
        end

        # --------------- #

        it "should return a kind of 200 if admin is logged in" do
          custom_sign_in @admin
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(response.status).to eq(200)
          bay_kind4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "no record" do
      it "should return a kind of 422 if record cant be found" do
        custom_sign_in @admin
        #NOTE: this is due to the user model having a bay_kind record (must add 2 - not 1)
        put :update, format: :json, :id => @bay_kind3.id + 2, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return a kind of 422 if bay_kind name has already been taken" do
        custom_sign_in @admin
        bay_kind4 = FactoryGirl.create(:bay_kind)
        put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => @bay_kind1.name.to_s, :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(422)
        bay_kind4.destroy
      end

      # --------------- #

      it "should return a kind of 422 if bay_kind name is blank" do
        custom_sign_in @admin
        bay_kind4 = FactoryGirl.create(:bay_kind)
        put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => nil, :description => "test description", :credits_per_hour => 1}
        expect(response.status).to eq(422)
        bay_kind4.destroy
      end

      # --------------- #

      it "should return a kind of 422 if bay_kind credits_per_hour is blank" do
        custom_sign_in @admin
        bay_kind4 = FactoryGirl.create(:bay_kind)
        put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => nil}
        expect(response.status).to eq(422)
        bay_kind4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response data" do
      context "no record" do
        it "should return the correct error response if the bay_kind id can't be found" do
          custom_sign_in @admin
          #NOTE: this is due to the user model having a bay_kind record
          put :update, format: :json, :id => @bay_kind3.id + 2, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to eq("The bay kind with id #{@bay_kind3.id + 2} could not be found.")
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "authentication" do
        it "should return - Authorized users only. - if no one is not logged in" do
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          bay_kind4.destroy
        end

        # --------------- #

        it "should return - Authorized users only. - if employee is logged in" do
          custom_sign_in @employee
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          bay_kind4.destroy
        end

        # --------------- #

        it "should return - Authorized users only. - if user is logged in" do
          custom_sign_in @user
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          bay_kind4.destroy
        end

        # --------------- #

        it "should return data of the updated bay_kind if no validation errors and user logged in" do
          custom_sign_in @admin
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['data']['name'].to_s).to eq("test name")
          expect(JSON.parse(response.body)['data']['id'].to_s).to eq("#{bay_kind4.id}")
          bay_kind4.destroy
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "messages" do
        it "should return Name Can't be blank if name is blank" do
          custom_sign_in @admin
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => nil, :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
          bay_kind4.destroy
        end

        # --------------- #

        it "should return Description Can't be blank if description is blank" do
          custom_sign_in @admin
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => nil, :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Description can't be blank")
          bay_kind4.destroy
        end

        # --------------- #

        it "should return Credits per hour Can't be blank if credits_per_hour is blank" do
          custom_sign_in @admin
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Credits per hour can't be blank")
          bay_kind4.destroy
        end

        # --------------- #

        it "should return Name is already taken if name has already been taken" do
          custom_sign_in @admin
          bay_kind4 = FactoryGirl.create(:bay_kind)
          put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => @bay_kind1.name.to_s, :description => "test description", :credits_per_hour => 1}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
          bay_kind4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "db creation" do
      it "should not create or delete a record from the db when updating" do
        custom_sign_in @admin
        bay_kind4 = FactoryGirl.create(:bay_kind)
        expect {put :update, format: :json, :id => bay_kind4.id, :bay_kind => {:name => "test name", :description => "test description", :credits_per_hour => 1}}.to change(BayKind, :count).by(0)
        bay_kind4.destroy
      end
    end
  end
end
