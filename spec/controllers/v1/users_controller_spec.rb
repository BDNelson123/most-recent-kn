require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::UsersController, :type => :api do
  before(:all) do
    create_user_employee_admin
  end

  # destroying the clubs & users objects after tests run
  after(:all) do
    delete_factories
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # DESTROY action tests
  describe "#destroy" do
    before(:each) do
      @user_destroy = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    end

    context "authentication & response status" do
      it "should return a response status of 401 if no one is not logged in" do
        delete :destroy, format: :json, :id => @user_destroy.id 
        expect(response.status).to eq(401)
        @user_destroy.destroy
      end

      # --------------- #

      it "should return a response status of 401 if user is logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @user_destroy.id 
        expect(response.status).to eq(401)
        @user_destroy.destroy
      end

      # --------------- #

      it "should return a response status of 401 if employee is logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @user_destroy.id 
        expect(response.status).to eq(401)
        @user_destroy.destroy
      end

      # --------------- #

      it "should return a response status of 202 if admin is logged in" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @user_destroy.id 
        expect(response.status).to eq(202)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "user record deletion" do
      it "should delete record from db" do
        custom_sign_in @admin
        expect {delete :destroy, format: :json, :id => @user_destroy.id}.to change(User, :count).by(-1)
      end

      # --------------- #

      it "should not add new record to db - not signed in" do
        expect {delete :destroy, format: :json, :id => @user_destroy.id}.to change(User, :count).by(0)
        delete :destroy, format: :json, :id => @user_destroy.id 
        @user_destroy.destroy
      end

      # --------------- #

      it "should not add new record to db - user signed in" do
        custom_sign_in @user
        expect {delete :destroy, format: :json, :id => @user_destroy.id}.to change(User, :count).by(0)
        delete :destroy, format: :json, :id => @user_destroy.id 
        @user_destroy.destroy
      end

      # --------------- #

      it "should not add new record to db - employee signed in" do
        custom_sign_in @employee
        expect {delete :destroy, format: :json, :id => @user_destroy.id}.to change(User, :count).by(0)
        delete :destroy, format: :json, :id => @user_destroy.id 
        @user_destroy.destroy
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct response body" do
      it "should send back validation that user is not authorized - not logged in" do
        delete :destroy, format: :json, :id => @user_destroy.id
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
        @user_destroy.destroy
      end

      # --------------- #

      it "should send back validation that user is not authorized - user logged in" do
        custom_sign_in @user
        delete :destroy, format: :json, :id => @user_destroy.id
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
        @user_destroy.destroy
      end

      # --------------- #

      it "should send back validation that user is not authorized - employee logged in" do
        custom_sign_in @employee
        delete :destroy, format: :json, :id => @user_destroy.id
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
        @user_destroy.destroy
      end

      # --------------- #

      it "should send back validation that record has been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @user_destroy.id
        expect(JSON.parse(response.body)['data'].to_s).to include("The user with id #{@user_destroy.id} has been deleted.")
      end

      # --------------- #

      it "should send back validation that record has not been deleted" do
        custom_sign_in @admin
        delete :destroy, format: :json, :id => @user_destroy.id + 100
        expect(JSON.parse(response.body)['errors'].to_s).to include("The user with id #{@user_destroy.id + 100} could not be found.")
        @user_destroy.destroy
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  describe "#index" do
    context "authentication" do
      context "responde code" do
        it "admin must be signed in to get 200 response" do
          custom_sign_in @admin
          get :index
          expect(response.status).to eq(200)
        end

        # --------------- #

        it "user will get 401 response" do
          custom_sign_in @user
          get :index
          expect(response.status).to eq(401)
        end

        # --------------- #

        it "employee will get 200 response" do
          custom_sign_in @employee
          get :index
          expect(response.status).to eq(200)
        end

        # --------------- #

        it "will get 401 response if not logged in" do
          get :index
          expect(response.status).to eq(401)
        end
      end

      context "response message" do
        it "admin must be signed in to get data back" do
          custom_sign_in @admin
          get :index
          expect(JSON.parse(response.body)["data"][0]["email"]).to eq(@user.email)
        end

        # --------------- #

        it "user will get Authorized users only message" do
          custom_sign_in @user
          get :index
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
        end

        # --------------- #

        it "employee will get data response" do
          custom_sign_in @employee
          get :index
          expect(JSON.parse(response.body)["data"][0]["email"]).to eq(@user.email)
        end

        # --------------- #

        it "no one signed in will get authorized users only message" do
          get :index
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
        end
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

        # ------------------------------ #
        # ------------------------------ #

        context "search" do
          it "should return at least 1 result for name" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.name.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for address" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.address.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for address2" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.address2.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for city" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.city.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for state" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.state.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for zip" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.zip.to_i
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for phone" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.phone.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for dob" do
            custom_sign_in @admin
            get :index, format: :json, :search => @user.dob.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 1 result for club name" do
            custom_sign_in @admin
            get :index, format: :json, :search => @club.name.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 1
          end

          # --------------- #

          it "should return at least 2 results for package name" do
            custom_sign_in @admin

            package = FactoryGirl.create(:package)
            user2 = FactoryGirl.create(:user, :package_id => package.id, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
            user3 = FactoryGirl.create(:user, :package_id => package.id, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)

            get :index, format: :json, :search => package.name.to_s
            expect(JSON.parse(response.body)['data'].length).to be >= 2

            package.destroy
            user2.destroy
            user3.destroy
          end

          # ------------------------------ #
          # ------------------------------ #

          context "where" do
            it "should return the correct values when searching with where statement" do
              custom_sign_in @admin

              user2 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
              user3 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)

              get :index, format: :json, :where => "users.id>'#{@user.id}'", :search => @club.name.to_s, :order_direction => "ASC"
              expect(JSON.parse(response.body)['data'][0]['user_name']).to eq(user2.name.to_s)
              expect(JSON.parse(response.body)['data'][1]['user_name']).to eq(user3.name.to_s)
              expect(JSON.parse(response.body)['data'].length).to be >= 2

              user2.destroy
              user3.destroy
            end

            # --------------- #

            it "should return the correct values when searching with where statement, order_direction = DESC, per_page = 2, and page = 2" do
              custom_sign_in @admin

              user2 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
              user3 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
              user4 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
              user5 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)

              get :index, format: :json, :where => "users.id>'#{@user.id}'", :search => @club.name.to_s, :per_page => 2, :page => 2, :order_direction => "DESC"
              expect(JSON.parse(response.body)['data'][0]['id']).to eq(user3.id.to_i)
              expect(JSON.parse(response.body)['data'][1]['id']).to eq(user2.id.to_i)
              expect(JSON.parse(response.body)['data'][0]['user_name']).to eq(user3.name.to_s)
              expect(JSON.parse(response.body)['data'][1]['user_name']).to eq(user2.name.to_s)
              expect(JSON.parse(response.body)['data'].length).to eq(2)

              user2.destroy
              user3.destroy
              user4.destroy
              user5.destroy
            end
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "results length" do
          it "should return 15 results for the first page if admin logged in" do
            custom_sign_in @admin
            get :index, format: :json, :page => 1
            expect(JSON.parse(response.body)['data'].length).to eq(15)
          end

          # --------------- #

          it "should return 15 results for the first page if employee logged in" do
            custom_sign_in @employee
            get :index, format: :json, :page => 1
            expect(JSON.parse(response.body)['data'].length).to eq(15)
          end

          # --------------- #

          it "should return 6 results for the second page" do
            custom_sign_in @admin
            get :index, format: :json, :page => 2
            expect(JSON.parse(response.body)['data'].length).to eq(12)
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

          it "should return 6 results for the third page with per_page param" do
            custom_sign_in @admin
            get :index, format: :json, :per_page => 10, :page => 3
            expect(JSON.parse(response.body)['data'].length).to eq(7)
          end
        end

        # ------------------------------ #
        # ------------------------------ #

        context "order by" do
          context "user_name" do
            it "should return user with name of 'a' for first result when ordering by name asc" do
              custom_sign_in @admin
              get :index, format: :json, :order_by => "users.name", :order_direction => "ASC"
              expect(JSON.parse(response.body)["data"][0]["user_name"].downcase).to start_with("a")
            end

            # --------------- #

            it "should return user with name of 'z' for first result when ordering by name desc" do
              custom_sign_in @admin
              get :index, format: :json, :order_by => "users.name", :order_direction => "DESC"
              expect(JSON.parse(response.body)["data"][0]["user_name"].downcase).to start_with("z")
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
      context "response status" do
        it "should return 200 if admin is logged in" do
          custom_sign_in @admin
          get :show, { :id => @user.id }
          expect(response.status).to eq(200)
        end

        # --------------- #

        it "should return 200 if employee is logged in" do
          custom_sign_in @employee
          get :show, { :id => @user.id }
          expect(response.status).to eq(200)
        end

        # --------------- #

        it "should return 200 if user is logged in" do
          custom_sign_in @user
          get :show, { :id => @user.id }
          expect(response.status).to eq(200)
        end

        # --------------- #

        it "should return 401 if no one is logged in" do
          get :show, { :id => @user.id }
          expect(response.status).to eq(401)
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "response message" do
        it "should return data if admin is logged in" do
          custom_sign_in @admin
          get :show, { :id => @user.id }
          expect(JSON.parse(response.body)["data"]["email"]).to eq(@user.email)
        end

        # --------------- #

        it "should return data if employee is logged in" do
          custom_sign_in @employee
          get :show, { :id => @user.id }
          expect(JSON.parse(response.body)["data"]["email"]).to eq(@user.email)
        end

        # --------------- #

        it "should return data if user is logged in" do
          custom_sign_in @user
          get :show, { :id => @user.id }
          expect(JSON.parse(response.body)["data"]["email"]).to eq(@user.email)
        end

        # --------------- #

        it "should return authorization failure message" do
          get :show, { :id => @user.id }
          expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
        end
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "cant find user id" do
      it "should return the correct error if the user id can't be found" do
        custom_sign_in @admin
        get :show, { 'id' => @user.id + 1 }
        expect(JSON.parse(response.body)['errors'].to_s).to eq("The user with id #{@user.id + 1} could not be found.")
      end

      # --------------- #

      it "should return the correct status if the club id can't be found" do
        custom_sign_in @admin
        get :show, { 'id' => @user.id + 1 }
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "results number" do
      it "should return " do
        custom_sign_in @admin
        get :show, { 'id' => @user.id }
        expect(JSON.parse(response.body)['data'].length).to eq(29)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "correct results" do
      it "should return " do
        custom_sign_in @admin
        get :show, { 'id' => @user.id }
        expect(JSON.parse(response.body)['data']['user_name']).to eq(@user.name.to_s)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "find by id/email/phone" do
      it "should return one result when find_by_id" do
        custom_sign_in @admin
        get :show, :format => :json, :id => @user.id
        expect(JSON.parse(response.body)['data'].length).to eq(29)
        expect(JSON.parse(response.body)['data']['email']).to eq(@user.email)
      end

      # --------------- #

      it "should return one result when find_by_email" do
        custom_sign_in @admin
        get :show, :format => :json, :type => "email", :id => @user.email
        expect(JSON.parse(response.body)['data'].length).to eq(29)
        expect(JSON.parse(response.body)['data']['email']).to eq(@user.email)
      end

      # --------------- #

      it "should return one result when find_by_phone" do
        custom_sign_in @admin
        get :show, :format => :json, :type => "phone", :id => @user.phone
        expect(JSON.parse(response.body)['data'].length).to eq(29)
        expect(JSON.parse(response.body)['data']['phone']).to eq(@user.phone)
      end
    end
  end
end
