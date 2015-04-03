require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::UsersController, :type => :api do
  before(:all) do
    create_user
  end

  # destroying the clubs & users objects after tests run
  after(:all) do
    delete_factories
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  describe "#index" do
    context "authentication" do
      it "user must be signed in to get 200 response" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        get :index
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)["data"][0]["email"]).to eq(@user.email)
      end

      # --------------- #

      it "user will get 401 response if not logged in" do
        get :index
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)).to eq({"errors"=>["Authorized users only."]})
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "pagination" do
      context "page" do
        before(:all) do
          @club_page = FactoryGirl.create(:club)
          @club2_page = FactoryGirl.create(:club)
          @level_page = FactoryGirl.create(:level)
          @income_page = FactoryGirl.create(:income)

          ("a".."z").each do |u|
            user = FactoryGirl.build(:user, :name => u, :iron_club_id => @club_page.id, :wood_club_id => @club2_page.id, :level_id => @level_page.id, :income_id => @income_page.id)
            user.skip_confirmation!
            user.save!
          end
        end

        after(:all) do
          @club_page.delete
          @club2_page.delete
          @level_page.delete
          @income_page.delete
          User.where(:iron_club_id => @club_page.id, :wood_club_id => @club2_page.id, :level_id => @level_page.id, :income_id => @income_page.id).destroy_all
        end

        context "authentication" do
          context "response status" do
            it "should return a response of 401 - not logged in" do
              get :index
              expect(response.status).to eq(401)
            end

            # --------------- #

            it "should return a response of 200" do
              sign_in @user
              request.headers.merge!(@user.create_new_auth_token)

              get :index
              expect(response.status).to eq(200)
            end
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
            expect(JSON.parse(response.body)['data'].length).to eq(12)
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

          it "should return 6 results for the third page with per_page param" do
            sign_in @user
            request.headers.merge!(@user.create_new_auth_token)

            get :index, format: :json, :per_page => 10, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(7)
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

  # SHOW action tests
  describe "#show" do
    context "authentication" do
      it "user must be signed in to get 200 response" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)
        get :show, { :id => @user.id }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)["data"]["email"]).to eq(@user.email)
      end

      # --------------- #

      it "get user show action - user will get 401 response if not logged in" do
        get :show, { :id => @user.id }
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)).to eq({"errors"=>["Authorized users only."]})
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "cant find user id" do
      it "should return the correct error if the user id can't be found" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        get :show, { 'id' => @user.id + 1 }
        expect(JSON.parse(response.body)['errors'].to_s).to eq("The user with id #{@user.id + 1} could not be found.")
      end

      # --------------- #

      it "should return the correct status if the club id can't be found" do
        sign_in @user
        request.headers.merge!(@user.create_new_auth_token)

        get :show, { 'id' => @user.id + 1 }
        expect(response.status).to eq(422)
      end
    end
  end
end
