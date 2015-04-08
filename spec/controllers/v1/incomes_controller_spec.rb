require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::IncomesController, :type => :api do
  before(:all) do
    @income1 = FactoryGirl.create(:income)
    @income2 = FactoryGirl.create(:income)
    @income3 = FactoryGirl.create(:income)
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
        post :create, format: :json, :income => {:name => "test name", :description => nil}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if user is not logged in" do
        custom_sign_in @user
        post :create, format: :json, :income => {:name => "test name", :description => nil}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if employee is not logged in" do
        custom_sign_in @employee
        post :create, format: :json, :income => {:name => "test name", :description => nil}
        expect(response.status).to eq(401)
      end

      # --------------- #
      it "should return a response status of 201 if user is logged in" do
        custom_sign_in @admin
        post :create, format: :json, :income => {:name => "test name", :description => nil}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response status" do
      it "should return a response status of 422 if record is not created - no name" do
        custom_sign_in @admin
        post :create, format: :json, :income => {:name => nil, :description => nil}
        expect(response.status).to eq(422)
      end

      # --------------- #

      it "should return a response status of 422 if record already exists - validation for unique name" do
        custom_sign_in @admin
        post :create, format: :json, :income => {:name => @income1.name.to_s, :description => nil}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "income record creation" do
      it "should add new record to db" do
        custom_sign_in @admin
        expect {post :create, format: :json, :income => {:name => "test name", :description => nil}}.to change(Income, :count).by(1)
      end

      # --------------- #

      it "should not add new record to db - no one signed in" do
        expect {post :create, format: :json, :income => {:name => "test name", :description => nil}}.to change(Income, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - user signed in" do
        custom_sign_in @user
        expect {post :create, format: :json, :income => {:name => "test name", :description => nil}}.to change(Income, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - employee signed in" do
        custom_sign_in @employee
        expect {post :create, format: :json, :income => {:name => "test name", :description => nil}}.to change(Income, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - nil" do
        custom_sign_in @admin
        expect {post :create, format: :json, :income => {:name => nil, :description => nil}}.to change(Income, :count).by(0)
      end

      # --------------- #

      it "should not add new record to db - validation fail for name - not unique" do
        custom_sign_in @admin
        expect {post :create, format: :json, :income => {:name => @income1.name.to_s, :description => nil}}.to change(Income, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "returned data" do
      it "should return the object id and name in the data hash" do
        custom_sign_in @admin
        post :create, format: :json, :income => {:name => "thisisasuperdupertest", :description => nil}
        expect(JSON.parse(response.body)['data'].to_s).to include("\"name\"=>\"thisisasuperdupertest\"")
      end

      # --------------- #

      it "should return the validation error for name already being taken" do
        custom_sign_in @admin
        post :create, format: :json, :income => {:name => @income1.name.to_s, :description => nil}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        custom_sign_in @admin
        post :create, format: :json, :income => {:name => nil, :description => nil}
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
      @income4 = FactoryGirl.create(:income)
    end

    after(:each) do
      @income4.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response status" do
      it "should return a response status of 401 if no one is logged in" do
        delete :destroy, format: :json, :id => @income4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if user is logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @income4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 401 if employee is logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @income4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 202 if user is logged in" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @income4.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "income record deletion" do
      it "should add new record to db" do
        custom_sign_in @admin
        expect {delete :destroy, format: :json, :id => @income4.id}.to change(Income, :count).by(-1)
      end

      # --------------- #

      it "should not delete record from db - no one signed in" do
        expect {delete :destroy, format: :json, :id => @income4.id}.to change(Income, :count).by(0)
      end

      # --------------- #

      it "should not delete record from db - user signed in" do
        custom_sign_in @user
        expect {delete :destroy, format: :json, :id => @income4.id}.to change(Income, :count).by(0)
      end

      # --------------- #

      it "should not delete record from db - employee signed in" do
        custom_sign_in @employee
        expect {delete :destroy, format: :json, :id => @income4.id}.to change(Income, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @income4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that user is not authorized - user logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @income4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that user is not authorized - user logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @income4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @income4.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The income with id #{@income4.id} has been deleted.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @income4.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The income with id #{@income4.id + 1} could not be found.")
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
      expect(JSON.parse(response.body)['data'].length).to eq(4) # user creation adds an income
    end

    # --------------- #

    # NOTE: index controller orders by name desc
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@income1.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@income2.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@income3.name.to_s)
    end

    # ------------------------------ #
    # ------------------------------ #

    context "where_attributes" do
      it "should return 3 results where id > @income1.id" do
        get :index, format: :json, :where => "id > #{@income1.id}"
        expect(JSON.parse(response.body)['data'].length).to eq(3)
      end

      # --------------- #

      it "should return 1 result where name = @income1.name" do
        get :index, format: :json, :where => "name='#{@income1.name.to_s}'"
        expect(JSON.parse(response.body)['data'].length).to eq(1)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@income1.name.to_s)
      end

      # --------------- #

      it "should not return an error if the query is valid but no results were returned" do
        get :index, format: :json, :where => "name='this wont give any result'"
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return an error if the query is invalid" do
        get :index, format: :json, :where => "testtesttest='#{@income1.name.to_s}'"
        expect(JSON.parse(response.body)['errors']).to eq("Your query is invalid.")
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    #NOTE: create_user has an income in it.  4 income models have been created.
    context "count" do
      it "should return 4 results" do
        get :index, format: :json, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(4)
      end

      # --------------- #

      it "should return 1 result with a where statement of id > @income2.id" do
        get :index, format: :json, :count => "true", :where => "id>'#{@income2.id}'"
        expect(JSON.parse(response.body)['data']['count']).to eq(2)
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
        get :index, format: :json, :search => @income1.name.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :where => "id>'#{@income1.id}'", :search => @income2.name.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@income2.name.to_s)
      end

      # --------------- #

      it "should return 0 results" do
        get :index, format: :json, :where => "id>'#{@income1.id}'", :search => @income1.name.to_s
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(JSON.parse(response.body)['data']).to_not include(@income1.name.to_s)
      end

      # --------------- #

      it "should return a value of 1 when user searches for @income1.name and wants to count it" do
        get :index, format: :json, :search => @income1.name.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 2 when user searches for @income1.name and wants to count it with a where statement - new record used" do
        income4 = FactoryGirl.create(:income, :name => @income2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@income1.id}'", :search => @income2.name.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(2)
        income4.destroy
      end

      # --------------- #

      it "should return the correct values when searching with where statement" do
        income4 = FactoryGirl.create(:income, :name => @income2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@income1.id}'", :search => @income2.name.to_s, :order_direction => "ASC"
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@income2.name.to_s)
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(income4.name.to_s)
        income4.destroy
      end

      # --------------- #

      it "should return the correct values when searching with where statement - order desc" do
        income4 = FactoryGirl.create(:income, :name => @income2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@income1.id}'", :search => @income2.name.to_s, :order_direction => "DESC"
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(@income2.name.to_s)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(income4.name.to_s)
        income4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    #NOTE: there are 30 results - 26 from alphabet, 3 from before_all and 1 from create_user
    context "pagination" do
      context "page" do
        before(:all) do
          ("a".."z").each do |u|
            FactoryGirl.create(:income, :name => u)
          end
        end

        after(:all) do
          ("a".."z").each do |u|
            Income.where(:name => u).destroy_all
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
            expect(JSON.parse(response.body)['data'].length).to eq(15)
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
            expect(JSON.parse(response.body)['data'].length).to eq(10)
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
      get :show, { 'id' => @income1.id }
      expect(response.status).to eq(200)
    end

    # --------------- #

    it "should return 1 record" do
      get :show, { 'id' => @income1.id }
      expect(JSON.parse(response.body)['data'].length).to eq(2) # 2 fields for one record (id and name)
    end

    # --------------- #

    it "should return the correct data for income1" do
      get :show, { 'id' => @income1.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@income1.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@income1.name.to_s)
    end

    # --------------- #

    it "should return the correct data for income2" do
      get :show, { 'id' => @income2.id }
      expect(JSON.parse(response.body)['data']['id'].to_i).to eq(@income2.id.to_i)
      expect(JSON.parse(response.body)['data']['name'].to_s).to eq(@income2.name.to_s)
    end

    # --------------- #

    it "should return the correct error if the income id can't be found" do
      #NOTE: this is due to the user model having an income record
      get :show, { 'id' => @income3.id + 2 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The income with id #{@income3.id + 2} could not be found.")
    end

    # --------------- #

    it "should return the correct status if the income id can't be found" do
      #NOTE: this is due to the user model having an income record
      get :show, { 'id' => @income3.id + 2 }
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
        it "should return a status of 422 if no one logged in" do
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(response.status).to eq(401)
          income4.destroy
        end

        # --------------- #

        it "should return a status of 422 if user is logged in" do
          custom_sign_in @user
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(response.status).to eq(401)
          income4.destroy
        end

        # --------------- #

        it "should return a status of 422 if employee is logged in" do
          custom_sign_in @employee
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(response.status).to eq(401)
          income4.destroy
        end

        # --------------- #

        it "should return a status of 200 if admin is logged in" do
          custom_sign_in @admin
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(response.status).to eq(200)
          income4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "no record" do
      it "should return a status of 422 if record cant be found" do
        custom_sign_in @admin
        #NOTE: this is due to the user model having a income record (must add 2 - not 1)
        put :update, format: :json, :id => @income3.id + 2, :income => {:name => "test name", :description => nil}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return a status of 422 if income name has already been taken" do
        custom_sign_in @admin
        income4 = FactoryGirl.create(:income)
        put :update, format: :json, :id => income4.id, :income => {:name => @income1.name.to_s, :description => nil}
        expect(response.status).to eq(422)
        income4.destroy
      end

      # --------------- #

      it "should return a status of 422 if income name is blank" do
        custom_sign_in @admin
        income4 = FactoryGirl.create(:income)
        put :update, format: :json, :id => income4.id, :income => {:name => nil, :description => nil}
        expect(response.status).to eq(422)
        income4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response data" do
      context "no record" do
        it "should return the correct error response if the income id can't be found" do
          custom_sign_in @admin
          #NOTE: this is due to the user model having a income record
          put :update, format: :json, :id => @income3.id + 2, :income => {:name => "test name", :description => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to eq("The income with id #{@income3.id + 2} could not be found.")
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "authentication" do
        it "should return - Authorized users only. - if no one is not logged in" do
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          income4.destroy
        end

        # --------------- #

        it "should return - Authorized users only. - if employee is logged in" do
          custom_sign_in @employee
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          income4.destroy
        end

        # --------------- #

        it "should return - Authorized users only. - if user is logged in" do
          custom_sign_in @user
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          income4.destroy
        end

        # --------------- #

        it "should return data of the updated income if no validation errors and user logged in" do
          custom_sign_in @admin
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}
          expect(JSON.parse(response.body)['data']['name'].to_s).to eq("test name")
          expect(JSON.parse(response.body)['data']['id'].to_s).to eq("#{income4.id}")
          income4.destroy
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "messages" do
        it "should return Name Can't be blank if name is blank" do
          custom_sign_in @admin
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => nil, :description => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
          income4.destroy
        end

        # --------------- #

        it "should return Name is already taken if name has already been taken" do
          custom_sign_in @admin
          income4 = FactoryGirl.create(:income)
          put :update, format: :json, :id => income4.id, :income => {:name => @income1.name.to_s, :description => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
          income4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "db creation" do
      it "should not create or delete a record from the db when updating" do
        custom_sign_in @admin
        income4 = FactoryGirl.create(:income)
        expect {put :update, format: :json, :id => income4.id, :income => {:name => "test name", :description => nil}}.to change(Income, :count).by(0)
        income4.destroy
      end
    end
  end
end
