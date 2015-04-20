require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::AssignmentsController do
  before(:all) do
    # create main user
    @income = FactoryGirl.create(:income)
    @level = FactoryGirl.create(:level)
    @club = FactoryGirl.create(:club)
    @user = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)

    # create admin and employee
    @admin = FactoryGirl.create(:admin)
    @employee = FactoryGirl.create(:employee)

    # allows us to create assignments on-the-fly in individual tests
    @bay_status = FactoryGirl.create(:bay_status)
    @bay_kind = FactoryGirl.create(:bay_kind)
    @bay = FactoryGirl.create(:bay, :bay_status_id => @bay_status.id, :bay_kind_id => @bay_kind.id)

    # create assignment1
    @user1 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @bay_status1 = FactoryGirl.create(:bay_status)
    @bay_kind1 = FactoryGirl.create(:bay_kind)
    @bay1 = FactoryGirl.create(:bay, :bay_status_id => @bay_status1.id, :bay_kind_id => @bay_kind1.id)
    @assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay1.id, :user_id => @user1.id)

    # create assignment2
    @user2 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @bay_status2 = FactoryGirl.create(:bay_status)
    @bay_kind2 = FactoryGirl.create(:bay_kind)
    @bay2 = FactoryGirl.create(:bay, :bay_status_id => @bay_status2.id, :bay_kind_id => @bay_kind2.id)
    @assignment2 = FactoryGirl.create(:assignment, :bay_id => @bay2.id, :user_id => @user2.id)

    # create assignment3
    @user3 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @bay_status3 = FactoryGirl.create(:bay_status)
    @bay_kind3 = FactoryGirl.create(:bay_kind)
    @bay3 = FactoryGirl.create(:bay, :bay_status_id => @bay_status3.id, :bay_kind_id => @bay_kind3.id)
    @assignment3 = FactoryGirl.create(:assignment, :bay_id => @bay3.id, :user_id => @user3.id)

    # arrays needed to delete all other factories besides these in individual tests
    @user_array = [@user.id,@user1.id,@user2.id,@user3.id]
    @bay_status_array = [@bay_status.id,@bay_status1.id,@bay_status2.id,@bay_status3.id]
    @bay_kind_array = [@bay_kind.id,@bay_kind1.id,@bay_kind2.id,@bay_kind3.id]
    @bay_array = [@bay.id,@bay1.id,@bay2.id,@bay3.id]
    @assignment_array = [@assignment1.id,@assignment2.id,@assignment3.id]
  end

  after(:all) do
    delete_factories
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # CREATE action tests
  describe "#create" do
    context "authentication & responses" do
      it "should return a response status of 401 if no one is not logged in" do
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should return a response status of 401 if user is logged in" do
        custom_sign_in @user
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      # --------------- #

      it "should return a response status of 201 and correct data if employee is logged in" do
        custom_sign_in @employee
        check_in_at = DateTime.now + 12.hours
        check_out_at = DateTime.now + 13.hours

        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => check_in_at, :check_out_at => check_out_at}

        # response status
        expect(response.status).to eq(201)

        # returned data
        expect(DateTime.parse(JSON.parse(response.body)['data']['check_in_at'].to_s)).to eq((check_in_at + 4.hours).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data']['check_out_at'].to_s)).to eq((check_out_at + 4.hours).to_s(:db))
        expect(JSON.parse(response.body)['data']['bays_number']).to eq(@bay.number)
        expect(JSON.parse(response.body)['data']['bay_kinds_name']).to eq(@bay_kind.name)
        expect(JSON.parse(response.body)['data']['bay_kinds_description']).to eq(@bay_kind.description)
        expect(JSON.parse(response.body)['data']['bay_statuses_name']).to eq(@bay_status.name)
        expect(JSON.parse(response.body)['data']['bay_statuses_description']).to eq(@bay_status.description)
        expect(JSON.parse(response.body)['data']['users_name']).to eq(@user.name)
        expect(JSON.parse(response.body)['data']['users_email']).to eq(@user.email)
      end

      # --------------- #

      it "should return a response status of 201 and correct data if admin is logged in" do
        custom_sign_in @admin
        check_in_at = DateTime.now + 12.hours
        check_out_at = DateTime.now + 13.hours

        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}

        # response status
        expect(response.status).to eq(201)

        # returned data
        expect(DateTime.parse(JSON.parse(response.body)['data']['check_in_at'].to_s)).to eq((check_in_at + 4.hours).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data']['check_out_at'].to_s)).to eq((check_out_at + 4.hours).to_s(:db))
        expect(JSON.parse(response.body)['data']['bays_number']).to eq(@bay.number)
        expect(JSON.parse(response.body)['data']['bay_kinds_name']).to eq(@bay_kind.name)
        expect(JSON.parse(response.body)['data']['bay_kinds_description']).to eq(@bay_kind.description)
        expect(JSON.parse(response.body)['data']['bay_statuses_name']).to eq(@bay_status.name)
        expect(JSON.parse(response.body)['data']['bay_statuses_description']).to eq(@bay_status.description)
        expect(JSON.parse(response.body)['data']['users_name']).to eq(@user.name)
        expect(JSON.parse(response.body)['data']['users_email']).to eq(@user.email)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "validation errors & response bodies" do
      it "should return a response status of 422 if record is not created - no bay_id" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => nil, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Bay can't be blank")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - no bay_id" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => nil, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("User can't be blank")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - no credits_per_hour" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => nil, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Credits per hour can't be blank")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - no check_in_at" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => nil, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check in at can't be blank")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - no check_out_at" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => nil}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check out at can't be blank")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - bay uniqueness" do
        custom_sign_in @admin
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        user1 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => user1.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Bay has already been taken")
        assignment1.destroy
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - user uniqueness" do
        custom_sign_in @admin
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        bay1 = FactoryGirl.create(:bay, :bay_status_id => @bay_status.id, :bay_kind_id => @bay_kind.id)
        post :create, format: :json, :assignment => {:bay_id => bay1.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("User has already been taken")
        assignment1.destroy
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - bay_id not valid" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay3.id + 1, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Bay must be a valid bay")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - user_id not valid" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user3.id + 1, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("User must be a valid user")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - parent_id not valid" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours, :parent_id => 1}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Parent must be a valid assignment")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - check_in_at being after check_out_at" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 13.hours, :check_out_at => DateTime.now + 12.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check out at must be after check in at")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - check_in_at being at same time as check_out_at" do
        custom_sign_in @admin
        time = DateTime.now + 12.hours
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => time, :check_out_at => time}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check out at must be after check in at")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - check_out_at being more than 12 hours after check_in_at" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 25.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check out at must be less than 12 hours after check in at")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - check_in_at being more than one hour in the past" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now - 90.minutes, :check_out_at => DateTime.now + 10.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check in at cannot be more than one hour in the past")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - check_out_at being in the past" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now - 1.minute}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Check out at cannot be in the past")
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "database record creation" do
      it "should not create a record if no one is not logged in" do
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create a record if user is logged in" do
        custom_sign_in @user
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should create a record if employee is logged in" do
        custom_sign_in @employee
        check_in_at = DateTime.now + 12.hours
        check_out_at = DateTime.now + 13.hours
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => check_in_at, :check_out_at => check_out_at}}.to change(Assignment, :count).by(1)
      end

      # --------------- #

      it "should create a record if admin is logged in" do
        custom_sign_in @admin
        check_in_at = DateTime.now + 12.hours
        check_out_at = DateTime.now + 13.hours
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(1)
      end

      # --------------- #

      it "should not create record in database - no bay_id" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => nil, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - no bay_id" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => nil, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - no credits_per_hour" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => nil, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - no check_in_at" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => nil, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - no check_out_at" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => nil}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - bay uniqueness" do
        custom_sign_in @admin
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        user1 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => user1.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
        assignment1.destroy
      end

      # --------------- #

      it "should not create record in database - user uniqueness" do
        custom_sign_in @admin
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        bay1 = FactoryGirl.create(:bay, :bay_status_id => @bay_status.id, :bay_kind_id => @bay_kind.id)
        expect {post :create, format: :json, :assignment => {:bay_id => bay1.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
        assignment1.destroy
      end

      # --------------- #

      it "should not create record in database - bay_id not valid" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id + 1, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - user_id not valid" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user3.id + 1, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - parent_id not valid" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours, :parent_id => 1}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - check_in_at being after check_out_at" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 13.hours, :check_out_at => DateTime.now + 12.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - check_in_at being at same time as check_out_at" do
        custom_sign_in @admin
        time = DateTime.now + 12.hours
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => time, :check_out_at => time}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - check_out_at being more than 12 hours after check_in_at" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 25.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - check_in_at being more than one hour in the past" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now - 90.minutes, :check_out_at => DateTime.now + 10.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - check_out_at being in the past" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now - 1.minute}}.to change(Assignment, :count).by(0)
      end
    end
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  # INDEX action tests
  describe "#index" do
    context "authentication" do
      it "should return a response of 401 - no one logged in" do
        get :index
        expect(response.status).to eq(401)
      end

      # --------------- #

      it "should return a response of 200 - user logged in" do
        custom_sign_in @user
        get :index
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return a response of 200 - employee logged in" do
        custom_sign_in @employee
        get :index
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return a response of 200 - admin logged in" do
        custom_sign_in @admin
        get :index
        expect(response.status).to eq(200)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    # NOTE: index controller orders by name desc
    context "correct values" do
      it "should return the correct ones" do
        custom_sign_in @admin
        get :index
        expect(JSON.parse(response.body)['data'][0]['bay_id'].to_i).to eq(@bay1.id.to_i)
        expect(JSON.parse(response.body)['data'][1]['bay_id'].to_i).to eq(@bay2.id.to_i)
        expect(JSON.parse(response.body)['data'][2]['bay_id'].to_i).to eq(@bay3.id.to_i)
        expect(JSON.parse(response.body)['data'][0]['user_id'].to_i).to eq(@user1.id.to_i)
        expect(JSON.parse(response.body)['data'][1]['user_id'].to_i).to eq(@user2.id.to_i)
        expect(JSON.parse(response.body)['data'][2]['user_id'].to_i).to eq(@user3.id.to_i)
        expect(JSON.parse(response.body)['data'][0]['assignments_credits_per_hour'].to_i).to eq(@assignment1.credits_per_hour.to_i)
        expect(JSON.parse(response.body)['data'][1]['assignments_credits_per_hour'].to_i).to eq(@assignment2.credits_per_hour.to_i)
        expect(JSON.parse(response.body)['data'][2]['assignments_credits_per_hour'].to_i).to eq(@assignment3.credits_per_hour.to_i)
        expect(DateTime.parse(JSON.parse(response.body)['data'][0]['check_in_at'].to_s)).to eq((@assignment1.check_in_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][1]['check_in_at'].to_s)).to eq((@assignment2.check_in_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][2]['check_in_at'].to_s)).to eq((@assignment3.check_in_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][0]['check_out_at'].to_s)).to eq((@assignment1.check_out_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][1]['check_out_at'].to_s)).to eq((@assignment2.check_out_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][2]['check_out_at'].to_s)).to eq((@assignment3.check_out_at).to_s(:db))
        expect(JSON.parse(response.body)['data'][0]['bays_number']).to eq(@bay1.number)
        expect(JSON.parse(response.body)['data'][1]['bays_number']).to eq(@bay2.number)
        expect(JSON.parse(response.body)['data'][2]['bays_number']).to eq(@bay3.number)
        expect(JSON.parse(response.body)['data'][0]['bay_kinds_name']).to eq(@bay_kind1.name)
        expect(JSON.parse(response.body)['data'][1]['bay_kinds_name']).to eq(@bay_kind2.name)
        expect(JSON.parse(response.body)['data'][2]['bay_kinds_name']).to eq(@bay_kind3.name)
        expect(JSON.parse(response.body)['data'][0]['bay_kinds_description']).to eq(@bay_kind1.description)
        expect(JSON.parse(response.body)['data'][1]['bay_kinds_description']).to eq(@bay_kind2.description)
        expect(JSON.parse(response.body)['data'][2]['bay_kinds_description']).to eq(@bay_kind3.description)
        expect(JSON.parse(response.body)['data'][0]['bay_statuses_name']).to eq(@bay_status1.name)
        expect(JSON.parse(response.body)['data'][1]['bay_statuses_name']).to eq(@bay_status2.name)
        expect(JSON.parse(response.body)['data'][2]['bay_statuses_name']).to eq(@bay_status3.name)
        expect(JSON.parse(response.body)['data'][0]['bay_statuses_description']).to eq(@bay_status1.description)
        expect(JSON.parse(response.body)['data'][1]['bay_statuses_description']).to eq(@bay_status2.description)
        expect(JSON.parse(response.body)['data'][2]['bay_statuses_description']).to eq(@bay_status3.description)
        expect(JSON.parse(response.body)['data'][0]['users_name']).to eq(@user1.name)
        expect(JSON.parse(response.body)['data'][1]['users_name']).to eq(@user2.name)
        expect(JSON.parse(response.body)['data'][2]['users_name']).to eq(@user3.name)
        expect(JSON.parse(response.body)['data'][0]['users_email']).to eq(@user1.email)
        expect(JSON.parse(response.body)['data'][1]['users_email']).to eq(@user2.email)
        expect(JSON.parse(response.body)['data'][2]['users_email']).to eq(@user3.email)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "length" do
      it "should return 3 records" do
        custom_sign_in @admin
        get :index
        expect(JSON.parse(response.body)['data'].length).to eq(3)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "where_attributes" do
      it "should return 2 results where id > @assignment1.id" do
        custom_sign_in @admin
        get :index, format: :json, :where => "assignments.id > #{@assignment1.id}"
        expect(JSON.parse(response.body)['data'].length).to eq(2)
      end

      # --------------- #

      it "should return correct incorrect query due to id not being namespaced" do
        custom_sign_in @admin
        get :index, format: :json, :where => "id > #{@assignment1.id}"
        expect(JSON.parse(response.body)['errors']).to include("Your query is invalid.")
      end

      # --------------- #

      it "should return correct values for where assignments.id >@assignment1.id " do
        custom_sign_in @admin
        get :index, format: :json, :where => "assignments.id > #{@assignment1.id}"
        expect(JSON.parse(response.body)['data'][0]['bay_id'].to_i).to eq(@bay2.id.to_i)
        expect(JSON.parse(response.body)['data'][1]['bay_id'].to_i).to eq(@bay3.id.to_i)
        expect(JSON.parse(response.body)['data'][0]['user_id'].to_i).to eq(@user2.id.to_i)
        expect(JSON.parse(response.body)['data'][1]['user_id'].to_i).to eq(@user3.id.to_i)
        expect(JSON.parse(response.body)['data'][0]['assignments_credits_per_hour'].to_i).to eq(@assignment2.credits_per_hour.to_i)
        expect(JSON.parse(response.body)['data'][1]['assignments_credits_per_hour'].to_i).to eq(@assignment3.credits_per_hour.to_i)
        expect(DateTime.parse(JSON.parse(response.body)['data'][0]['check_in_at'].to_s)).to eq((@assignment2.check_in_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][1]['check_in_at'].to_s)).to eq((@assignment3.check_in_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][0]['check_out_at'].to_s)).to eq((@assignment2.check_out_at).to_s(:db))
        expect(DateTime.parse(JSON.parse(response.body)['data'][1]['check_out_at'].to_s)).to eq((@assignment3.check_out_at).to_s(:db))
        expect(JSON.parse(response.body)['data'][0]['bays_number']).to eq(@bay2.number)
        expect(JSON.parse(response.body)['data'][1]['bays_number']).to eq(@bay3.number)
        expect(JSON.parse(response.body)['data'][0]['bay_kinds_name']).to eq(@bay_kind2.name)
        expect(JSON.parse(response.body)['data'][1]['bay_kinds_name']).to eq(@bay_kind3.name)
        expect(JSON.parse(response.body)['data'][0]['bay_kinds_description']).to eq(@bay_kind2.description)
        expect(JSON.parse(response.body)['data'][1]['bay_kinds_description']).to eq(@bay_kind3.description)
        expect(JSON.parse(response.body)['data'][0]['bay_statuses_name']).to eq(@bay_status2.name)
        expect(JSON.parse(response.body)['data'][1]['bay_statuses_name']).to eq(@bay_status3.name)
        expect(JSON.parse(response.body)['data'][0]['bay_statuses_description']).to eq(@bay_status2.description)
        expect(JSON.parse(response.body)['data'][1]['bay_statuses_description']).to eq(@bay_status3.description)
        expect(JSON.parse(response.body)['data'][0]['users_name']).to eq(@user2.name)
        expect(JSON.parse(response.body)['data'][1]['users_name']).to eq(@user3.name)
        expect(JSON.parse(response.body)['data'][0]['users_email']).to eq(@user2.email)
        expect(JSON.parse(response.body)['data'][1]['users_email']).to eq(@user3.email)
      end

      # --------------- #

      it "should return 1 result where bays_number = @bay2.number" do
        custom_sign_in @admin
        get :index, format: :json, :where => "bays.number='#{@bay2.number}'"
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['data'].length).to eq(1)
        expect(JSON.parse(response.body)['data'][0]['id'].to_i).to eq(@assignment2.id.to_i)
      end

      # --------------- #

      it "should not return an error if the query is valid but no results were returned" do
        custom_sign_in @admin
        get :index, format: :json, :where => "assignments.credits_per_hour='this wont give any result'"
        expect(JSON.parse(response.body)['data'].length).to eq(0)
        expect(response.status).to eq(200)
      end

      # --------------- #

      it "should return an error if the query is invalid" do
        custom_sign_in @admin
        get :index, format: :json, :where => "testtesttest='#{@bay2.number}'"
        expect(JSON.parse(response.body)['errors']).to eq("Your query is invalid.")
        expect(response.status).to eq(422)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "count" do
      it "should return 3 results" do
        custom_sign_in @admin
        get :index, format: :json, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to eq(3)
      end

      # --------------- #

      it "should return 2 results with a where statement of assignments.id > @assignment1.id" do
        custom_sign_in @admin
        get :index, format: :json, :count => "true", :where => "assignments.id>'#{@assignment1.id}'"
        expect(JSON.parse(response.body)['data']['count']).to eq(2)
      end

      # --------------- #

      it "should return 0 results if the query is valid but no results were returned" do
        custom_sign_in @admin
        get :index, format: :json, :count => "true", :where => "assignments.credits_per_hour='this wont give any result'"
        expect(JSON.parse(response.body)['data']['count']).to eq(0)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "search" do
      it "should return 1 result" do
        custom_sign_in @admin
        get :index, format: :json, :search => @user1.name
        expect(JSON.parse(response.body)['data'].length).to be >= 1
      end

      # --------------- #

      it "should return 1 result" do
        custom_sign_in @admin
        get :index, format: :json, :where => "assignments.id>'#{@assignment2.id}'", :search => @user3.name
        expect(JSON.parse(response.body)['data'].length).to be >= 1
        expect(JSON.parse(response.body)['data'][0]['users_name']).to eq(@user3.name)
      end

      # --------------- #

      it "should return 0 results" do
        custom_sign_in @admin
        get :index, format: :json, :where => "assignments.id>'#{@assignment1.id}'", :search => @user2.name
        expect(JSON.parse(response.body)['data']).to_not include(@user3.name)
      end

      # --------------- #

      it "should return a value of 1 when user searches for @user1.name and wants to count it" do
        custom_sign_in @admin
        get :index, format: :json, :search => @user2.name, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end

      # --------------- #

      it "should return a value of 1 when user searches for @user1.name and wants to count it with a where statement" do
        custom_sign_in @admin
        get :index, format: :json, :where => "assignments.id>'#{@assignment1.id}'", :search => @user2.name, :count => "true"
        expect(JSON.parse(response.body)['data']['count']).to be >= 1
      end
    end

    #NOTE: there are 29 results - 26 from alphabet, 3 from before_all
    context "pagination" do
      context "page" do
        before(:all) do
          ("a".."z").each do |u|
            user_page = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id, :name => u)
            bay_status_page = FactoryGirl.create(:bay_status)
            bay_kind_page = FactoryGirl.create(:bay_kind)
            bay_page = FactoryGirl.create(:bay, :bay_status_id => bay_status_page.id, :bay_kind_id => bay_kind_page.id)
            FactoryGirl.create(:assignment, :bay_id => bay_page.id, :user_id => user_page.id)
          end
        end

        after(:all) do
          ("a".."z").each do |u|
            Assignment.where("id NOT IN (?)", @assignment_array).destroy_all
            Bay.where("id NOT IN (?)", @bay_array).destroy_all
            BayKind.where("id NOT IN (?)", @bay_kind_array).destroy_all
            BayStatus.where("id NOT IN (?)", @bay_status_array).destroy_all
            User.where("id NOT IN (?)", @user_array).destroy_all
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

          it "should return 6 results for the second page" do
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

          it "should return 10 results for the third page with per_page param" do
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
              get :index, format: :json, :order_by => "users.name", :order_direction => "ASC"
              expect(JSON.parse(response.body)["data"][0]["users_name"].downcase).to start_with("a")
            end

            # --------------- #

            it "should return user with name of 'z' for first result when ordering by name desc" do
              custom_sign_in @admin
              get :index, format: :json, :order_by => "users_name", :order_direction => "DESC"
              expect(JSON.parse(response.body)["data"][0]["users_name"].downcase).to start_with("z")
            end
          end
        end
      end
    end
  end
end
