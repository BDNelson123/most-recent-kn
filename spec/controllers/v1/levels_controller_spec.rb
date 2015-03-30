require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::LevelsController, :type => :api do
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

  # DESTROY action tests
  describe "#destroy" do
    before(:each) do
      @level6 = FactoryGirl.create(:level)
    end

    after(:each) do
      @level6.destroy
    end

    # ------------------------------ #
    # ------------------------------ #

    context "authentication & response status" do
      it "should return a response status of 401 if user is not logged in" do
        delete :destroy, format: :json, :id => @level6.id 
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response status of 202 if user is logged in" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        delete :destroy, format: :json, :id => @level6.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "level record deletion" do
      it "should add new record to db" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        expect {delete :destroy, format: :json, :id => @level6.id}.to change(Level, :count).by(-1)
      end

      # --------------- #

      it "should not delete record from db - not signed in" do
        expect {delete :destroy, format: :json, :id => @level6.id}.to change(Level, :count).by(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @level6.id 
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @level6.id 
        expect(JSON.parse(response.body)['data'].to_s).to include("The level with id #{@level6.id} has been deleted.")
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        delete :destroy, format: :json, :id => @level6.id + 1 
        expect(JSON.parse(response.body)['errors'].to_s).to include("The level with id #{@level6.id + 1} could not be found.")
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

    # NOTE: there are 6 levels - one comes from create_user which would be the first one in the list
    it "should return the correct values" do
      get :index
      expect(JSON.parse(response.body)['data'][1]['name'].to_s).to eq(@level1.name.to_s)
      expect(JSON.parse(response.body)['data'][1]['handicap'].to_s).to eq(@level1.handicap.to_s)
      expect(JSON.parse(response.body)['data'][1]['description'].to_s).to eq(@level1.description.to_s)

      expect(JSON.parse(response.body)['data'][2]['name'].to_s).to eq(@level2.name.to_s)
      expect(JSON.parse(response.body)['data'][2]['handicap'].to_s).to eq(@level2.handicap.to_s)
      expect(JSON.parse(response.body)['data'][2]['description'].to_s).to eq(@level2.description.to_s)

      expect(JSON.parse(response.body)['data'][3]['name'].to_s).to eq(@level3.name.to_s)
      expect(JSON.parse(response.body)['data'][3]['handicap'].to_s).to eq(@level3.handicap.to_s)
      expect(JSON.parse(response.body)['data'][3]['description'].to_s).to eq(@level3.description.to_s)

      expect(JSON.parse(response.body)['data'][4]['name'].to_s).to eq(@level4.name.to_s)
      expect(JSON.parse(response.body)['data'][4]['handicap'].to_s).to eq(@level4.handicap.to_s)
      expect(JSON.parse(response.body)['data'][4]['description'].to_s).to eq(@level4.description.to_s)

      expect(JSON.parse(response.body)['data'][5]['name'].to_s).to eq(@level5.name.to_s)
      expect(JSON.parse(response.body)['data'][5]['handicap'].to_s).to eq(@level5.handicap.to_s)
      expect(JSON.parse(response.body)['data'][5]['description'].to_s).to eq(@level5.description.to_s)
    end

    # ------------------------------ #
    # ------------------------------ #

    #NOTE: there are 32 results - 26 from alphabet, 5 from before_all and 1 from create_user
    context "pagination" do
      context "page" do
        before(:all) do
          ("a".."z").each do |u|
            FactoryGirl.create(:level, :name => u)
          end
        end

        after(:all) do
          ("a".."z").each do |u|
            Level.where(:name => u).destroy_all
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
            expect(JSON.parse(response.body)['data'].length).to eq(15)
          end

          # --------------- #

          it "should return 0 results for the third page" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(2)
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
            expect(JSON.parse(response.body)['data'].length).to eq(10)
          end

          # --------------- #

          it "should return 2 results for the fourth page with per_page param" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :per_page => 10, :page => 4
            expect(JSON.parse(response.body)['data'].length).to eq(2)
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
              expect(JSON.parse(response.body)["data"][0]["name"]).to eq("a")
            end

            # --------------- #

            it "should return user with name of 'z' for first result when ordering by name desc" do
              sign_in @user
              request.headers.merge!(@user.create_new_auth_token)

              get :index, format: :json, :order_by => "name", :order_direction => "DESC"
              expect(JSON.parse(response.body)["data"][0]["name"]).to eq("z")
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
      level6 = Level.last
      get :show, { 'id' => level6.id + 2 }
      expect(JSON.parse(response.body)['errors'].to_s).to eq("The level with id #{level6.id + 2} could not be found.")
    end

    # --------------- #

    it "should return the correct status if the level id can't be found" do
      #NOTE: + 2 comes from user model needing to create a level
      level6 = Level.last
      get :show, { 'id' => level6.id + 2 }
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
          level6 = FactoryGirl.create(:level, :name => "test name", :description => "test description", :handicap => "test handicap")
          put :update, format: :json, :id => level6.id, :level => {:name => "test update name", :description => "test update description", :handicap => "test update handicap"}
          expect(response.status).to eq(401)
          level6.destroy
        end

        # --------------- #

        it "should return a status of 200 if user is logged in" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level, :name => "test name", :description => "test description", :handicap => "test handicap")
          put :update, format: :json, :id => level6.id, :level => {:name => "test update name", :description => "test update description", :handicap => "test update handicap"}
          expect(response.status).to eq(200)
          level6.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "no record" do
      it "should return a status of 422 if record cant be found" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        #NOTE: this is due to the user model having a level record (must add 2 - not 1)
        put :update, format: :json, :id => @level5.id + 2, :level => {:name => "test update name", :description => "test update description", :handicap => "test update handicap"}
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validations" do
      it "should return a status of 422 if level name has already been taken" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        level6 = FactoryGirl.create(:level)
        put :update, format: :json, :id => level6.id, :level => {:name => @level5.name.to_s}
        expect(response.status).to eq(422)
        level6.destroy
      end

      # --------------- #

      it "should return a status of 422 if level name is blank" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        level6 = FactoryGirl.create(:level, :name => "test name", :description => "test description", :handicap => "test handicap")
        put :update, format: :json, :id => level6.id, :level => {:name => ""}
        expect(response.status).to eq(422)
        level6.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "response data" do
      context "no record" do
        it "should return the correct error response if the level id can't be found" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          #NOTE: this is due to the user model having a level record
          put :update, format: :json, :id => @level5.id + 2, :level => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to eq("The level with id #{@level5.id + 2} could not be found.")
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "authentication" do
        it "should return - Authorized users only. - if user is not logged in" do
          level6 = FactoryGirl.create(:level, :name => "test name", :description => "test description", :handicap => "test handicap")
          put :update, format: :json, :id => level6.id, :level => {:name => "test"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
          level6.destroy
        end

        # --------------- #

        it "should return data of the updated level if no validation errors and user logged in" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level, :name => "test name", :description => "test description", :handicap => "test handicap")
          put :update, format: :json, :id => level6.id, :level => {:name => "test"}
          expect(JSON.parse(response.body)['data']['name'].to_s).to eq("test")
          expect(JSON.parse(response.body)['data']['id'].to_s).to eq("#{level6.id}")
          level6.destroy
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "messages" do
        it "should return Name Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level)
          put :update, format: :json, :id => level6.id, :level => {:name => "", :description => "test 2 description", :handicap => "test 2 handicap"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name can't be blank")
          level6.destroy
        end

        # --------------- #

        it "should return Description Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level)
          put :update, format: :json, :id => level6.id, :level => {:name => "test 2 name", :description => "", :handicap => "test 2 handicap"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Description can't be blank")
          level6.destroy
        end

        # --------------- #

        it "should return Handicap Can't be blank if name is blank" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level)
          put :update, format: :json, :id => level6.id, :level => {:name => "test 2 name", :description => "test 2 description", :handicap => ""}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Handicap can't be blank")
          level6.destroy
        end

        # --------------- #

        it "should return Name is already taken if name has already been taken" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level)
          put :update, format: :json, :id => level6.id, :level => {:name => @level3.name.to_s, :description => "test description", :handicap => "test handicap"}
          expect(JSON.parse(response.body)['errors'].to_s).to include("Name has already been taken")
          level6.destroy
        end

        # --------------- #

        it "should return no validation error for name already being taken" do
          sign_in @user
          request.headers.merge!(@user.create_new_auth_token)
          level6 = FactoryGirl.create(:level)
          put :update, format: :json, :id => level6.id, :level => {:name => level6.name.to_s, :description => "test description", :handicap => "test handicap"}
          expect(JSON.parse(response.body)['errors'].to_s).to_not include("Name has already been taken")
          level6.destroy
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "db creation" do
      it "should not create or delete a record from the db when updating" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        level6 = FactoryGirl.create(:level)
        expect {put :update, format: :json, :id => level6.id, :level => {:name => "test 2 name", :description => "test 2 description", :handicap => "test 2 handicap"}}.to change(Level, :count).by(0)
        level6.destroy
      end
    end
  end
end
