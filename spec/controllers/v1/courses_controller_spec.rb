require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::CoursesController, :type => :api do
  before(:all) do
    # have to give names here due to index action being sorted by name
    @course1 = FactoryGirl.create(:course, :name => "Cameron Park Country Course")
    @course2 = FactoryGirl.create(:course, :name => "La Quinta Country Course")
    @course3 = FactoryGirl.create(:course, :name => "Ponderosa Golf Course")
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
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 201 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}
        expect(response.status).to eq(201)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response status" do
      it "should return a response status of 422 if record is not created - no name" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => nil, :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}
        expect(response.status).to eq(422)
      end

      it "should return a response status of 422 if record is not created - no address" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => nil, :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}
        expect(response.status).to eq(422)
      end

      it "should return a response status of 422 if record is not created - no city" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => nil, :state => "test state", :zip => 11111}
        expect(response.status).to eq(422)
      end

      it "should return a response status of 422 if record is not created - no state" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => nil, :zip => 11111}
        expect(response.status).to eq(422)
      end

      it "should return a response status of 422 if record is not created - no zip" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test city", :zip => nil}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "course record creation" do
      it "should add new record to db - signed in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}}.to change(Course, :count).by(1)
      end

      it "should change db count by 0 - user not signed in" do
        expect {post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}}.to change(Course, :count).by(0)
      end

      it "should change db count by 0 - no name" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :course => {:name => nil, :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}}.to change(Course, :count).by(0)
      end

      it "should change db count by 0 - no address" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :course => {:name => "test name", :address => nil, :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}}.to change(Course, :count).by(0)
      end

      it "should change db count by 0 - no city" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => nil, :state => "test state", :zip => 11111}}.to change(Course, :count).by(0)
      end

      it "should change db count by 0 - no state" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => nil, :zip => 11111}}.to change(Course, :count).by(0)
      end

      it "should change db count by 0 - no zip" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test city", :zip => nil}}.to change(Course, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "returned data" do
      it "should return the object id and name in the data hash" do
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      it "should return the validation error for authentication" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}
        expect(JSON.parse(response.body)['data'].to_s).to include("\"name\"=>\"test name\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("\"address\"=>\"test address\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("\"address2\"=>\"test address2\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("\"city\"=>\"test city\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("\"state\"=>\"test state\"")
        expect(JSON.parse(response.body)['data'].to_s).to include("\"zip\"=>11111")
      end

      # --------------- #

      it "should return the validation error for name being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => nil, :address => "test address", :address2 => "test address2", :city => "test city", :state => "test city", :zip => 11111}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
      end

      # --------------- #

      it "should return the validation error for address being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => nil, :address2 => "test address2", :city => "test city", :state => "test city", :zip => 11111}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Address can't be blank")
      end

      # --------------- #

      it "should return the validation error for city being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => nil, :state => "test city", :zip => 11111}
        expect(JSON.parse(response.body)['errors'].to_s).to include("City can't be blank")
      end

      # --------------- #

      it "should return the validation error for state being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => nil, :zip => 11111}
        expect(JSON.parse(response.body)['errors'].to_s).to include("State can't be blank")
      end

      # --------------- #

      it "should return the validation error for zip being null" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        post :create, format: :json, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test city", :zip => nil}
        expect(JSON.parse(response.body)['errors'].to_s).to include("Zip can't be blank")
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
      expect(JSON.parse(response.body)['data'][0]['name'].to_s).to eq(@course1.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@course2.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@course3.name.to_s)
    end

    # ------------------------------ #
    # ------------------------------ #

    context "where_attributes" do
      # create_user does not have a course so only 2 courses should come after the first
      it "should return 2 results where id > @course1.id" do
        get :index, format: :json, :where => "id > #{@course1.id}"
        expect(JSON.parse(response.body)['data'].length).to eq(2)
      end

      # --------------- #

      it "should return 1 result where name = @course1.name" do
        get :index, format: :json, :where => "name='#{@course1.name.to_s}'"
        expect(JSON.parse(response.body)['data'].length).to eq(1)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@course1.name.to_s)
      end

      # --------------- #

      it "should not return an error if the query is valid but no results were returned" do
        get :index, format: :json, :where => "name='this wont give any result'"
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return an error if the query is invalid" do
        get :index, format: :json, :where => "testtesttest='#{@course1.name.to_s}'"
        expect(JSON.parse(response.body)['errors']).to eq("Your query is invalid.")
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    #NOTE: create_user does not have a course in it.  Only 3 course models created.
    context "count" do
      it "should return 3 results" do
        get :index, format: :json, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(3)
      end

      # --------------- #

      it "should return 1 result with a where statement of id > @course2.id" do
        get :index, format: :json, :count => "true", :where => "id>'#{@course2.id}'"
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
        get :index, format: :json, :search => @course1.name.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :search => @course2.address.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :search => @course3.address2.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :search => @course1.city.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :search => @course2.state.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :search => @course3.zip
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        get :index, format: :json, :where => "id>'#{@course1.id}'", :search => @course2.name.to_s
        expect(JSON.parse(response.body)['data'].length).to be >= 1
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@course2.name.to_s)
      end

      # --------------- #

      it "should return 0 results" do
        get :index, format: :json, :where => "id>'#{@course1.id}'", :search => @course1.name.to_s
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(JSON.parse(response.body)['data']).to_not include(@course1.name.to_s)
      end

      # --------------- #

      it "should return a value of 1 when user searches for @course1.name and wants to count it" do
        get :index, format: :json, :search => @course1.name.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 1 when user searches for @course1.name and wants to count it with a where statement" do
        get :index, format: :json, :where => "id>'#{@course1.id}'", :search => @course2.address.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 2 when user searches for @course1.name and wants to count it with a where statement - new record used" do
        course4 = FactoryGirl.create(:course, :name => @course2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@course1.id}'", :search => @course2.name.to_s, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(2)
        course4.destroy
      end

      # --------------- #

      it "should return the correct values when searching with where statement" do
        course4 = FactoryGirl.create(:course, :name => @course2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@course1.id}'", :search => @course2.name.to_s, :order_direction => "ASC"
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(@course2.name.to_s)
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(course4.name.to_s)
        course4.destroy
      end

      # --------------- #

      it "should return the correct values when searching with where statement - order desc" do
        course4 = FactoryGirl.create(:course, :name => @course2.name.to_s + "2")
        get :index, format: :json, :where => "id>'#{@course1.id}'", :search => @course2.name.to_s, :order_direction => "DESC"
        expect(JSON.parse(response.body)['data'][1]['name']).to eq(@course2.name.to_s)
        expect(JSON.parse(response.body)['data'][0]['name']).to eq(course4.name.to_s)
        course4.destroy
      end
    end

    #NOTE: there are 29 results - 26 from alphabet and 3 from before_all
    context "pagination" do
      context "page" do
        before(:all) do
          ("a".."z").each do |u|
            FactoryGirl.create(:course, :name => u)
          end
        end

        after(:all) do
          ("a".."z").each do |u|
            Course.where(:name => u).destroy_all
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "results length" do
          it "should return 15 results for the first page" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :page => 1
            expect(JSON.parse(response.body)['data'].length).to eq(15)
          end

          # --------------- #

          it "should return 6 results for the second page" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :page => 2
            expect(JSON.parse(response.body)['data'].length).to eq(14)
          end

          # --------------- #

          it "should return 0 results for the third page" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(0)
          end

          # --------------- #

          it "should return 10 results for the first page with per_page param" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :per_page => 10
            expect(JSON.parse(response.body)['data'].length).to eq(10)
          end

          # --------------- #

          it "should return 10 results for the third page with per_page param" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :per_page => 10, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(9)
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "order by" do
          context "name" do
            it "should return user with name of 'a' for first result when ordering by name asc" do
              sign_in @user
              request.headers.merge!(@user.create_new_auth_token)

              get :index, format: :json, :order_by => "name", :order_direction => "ASC"
              expect(JSON.parse(response.body)["data"][0]["name"].downcase).to start_with("a")
            end

            # --------------- #

            it "should return user with name of 'z' for first result when ordering by name desc" do
              sign_in @user
              request.headers.merge!(@user.create_new_auth_token)

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

  # DESTROY action tests
  describe "#destroy" do
    before(:each) do
      @course4 = FactoryGirl.create(:course)
    end

    after(:each) do
      @course4.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response status" do
      it "should return a response status of 401 if user is not logged in" do
        delete :destroy, format: :json, :id => @course4.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 202 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        delete :destroy, format: :json, :id => @course4.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "course record deletion" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {delete :destroy, format: :json, :id => @course4.id}.to change(Course, :count).by(-1)
      end

      # --------------- #

      it "should not delete record from db - not signed in" do
        expect {delete :destroy, format: :json, :id => @course4.id}.to change(Course, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @course4.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @course4.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The course with id #{@course4.id} has been deleted.")
      end

      # --------------- #

      it "should send back validation that record has NOT been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @course4.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The course with id #{@course4.id + 1} could not be found.")
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

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

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # UPDATE action tests
  describe "#update" do
    context "response status" do
      context "authentication" do
        it "should return a status of 422 if user is not logged in" do
          course4 = FactoryGirl.create(:course, :name => "Cleveland Golf")
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
          expect(response.status).to eq(401)
          course4.destroy
        end

        # --------------- #

        it "should return a status of 200 if user is logged in" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course, :name => "Cleveland Golf")
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
          expect(response.status).to eq(200)
          course4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "no record" do
      it "should return a status of 422 if record cant be found" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        #NOTE: this is due to the user model having a course record (must add 2 - not 1)
        put :update, format: :json, :id => @course3.id + 2, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return a status of 422 if course name is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        course4 = FactoryGirl.create(:course)
        put :update, format: :json, :id => course4.id, :course => {:name => nil, :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
        expect(response.status).to eq(422)
        course4.destroy
      end

      it "should return a status of 422 if course address is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        course4 = FactoryGirl.create(:course)
        put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => nil, :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
        expect(response.status).to eq(422)
        course4.destroy
      end

      it "should return a status of 422 if course city is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        course4 = FactoryGirl.create(:course)
        put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => nil, :state => "test state", :zip => 78749}
        expect(response.status).to eq(422)
        course4.destroy
      end

      it "should return a status of 422 if course state is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        course4 = FactoryGirl.create(:course)
        put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => nil, :zip => 78749}
        expect(response.status).to eq(422)
        course4.destroy
      end

      it "should return a status of 422 if course zip is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        course4 = FactoryGirl.create(:course)
        put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => nil}
        expect(response.status).to eq(422)
        course4.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response data" do
      context "no record" do
        it "should return the correct error response if the course id can't be found" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          #NOTE: this is due to the user model having a course record
          put :update, format: :json, :id => @course3.id + 2, :course => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to eq("The course with id #{@course3.id + 2} could not be found.")
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "authentication" do
        it "should return - Authorized users only. - if user is not logged in" do
          course4 = FactoryGirl.create(:course, :name => "Cleveland Golf")
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          course4.destroy
        end

        # --------------- #

        it "should return data of the updated course if no validation errors and user logged in" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course, :name => "Cleveland Golf")
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
          expect(JSON.parse(response.body)['data']['name'].to_s).to eq("test name")
          expect(JSON.parse(response.body)['data']['id'].to_s).to eq("#{course4.id}")
          course4.destroy
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "messages" do
        it "should return Name Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course)
          put :update, format: :json, :id => course4.id, :course => {:name => nil, :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
          course4.destroy
        end

        # --------------- #

        it "should return Address Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course)
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => nil, :address2 => "test address2", :city => "test city", :state => "test state", :zip => 78749}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Address can't be blank")
          course4.destroy
        end

        # --------------- #

        it "should return City Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course)
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => nil, :state => "test state", :zip => 78749}
          expect(JSON.parse(response.body)['errors'].to_s).to include("City can't be blank")
          course4.destroy
        end

        # --------------- #

        it "should return State Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course)
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => nil, :zip => 78749}
          expect(JSON.parse(response.body)['errors'].to_s).to include("State can't be blank")
          course4.destroy
        end

        # --------------- #

        it "should return Zip Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course)
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Zip can't be blank")
          course4.destroy
        end

        # --------------- #

        it "should return Zip Can't be blank if name is blank and Address Can't be Blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          course4 = FactoryGirl.create(:course)
          put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => nil, :address2 => "test address2", :city => "test city", :state => "test state", :zip => nil}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Zip can't be blank")
          expect(JSON.parse(response.body)['errors'].to_s).to include("Address can't be blank")
          course4.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "db creation" do
      it "should not create or delete a record from the db when updating" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        course4 = FactoryGirl.create(:course, :name => "Cleveland Golf")
        expect {put :update, format: :json, :id => course4.id, :course => {:name => "test name", :address => "test address", :address2 => "test address2", :city => "test city", :state => "test state", :zip => 11111}}.to change(Course, :count).by(0)
        course4.destroy
      end
    end
  end
end
