require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::AssignmentsController do
  before(:each) do
    create_user_employee_admin
    create_bay
  end

  after(:each) do
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
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - user uniqueness" do
        custom_sign_in @admin
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        bay1 = FactoryGirl.create(:bay, :bay_status_id => @bay_status.id, :bay_kind_id => @bay_kind.id)
        post :create, format: :json, :assignment => {:bay_id => bay1.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("User has already been taken")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - bay_id not valid" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id + 1, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Bay must be a valid bay")
      end

      # --------------- #

      it "should return a response status of 422 if record is not created - user_id not valid" do
        custom_sign_in @admin
        post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id + 1, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}
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
      end

      # --------------- #

      it "should not create record in database - user uniqueness" do
        custom_sign_in @admin
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        bay1 = FactoryGirl.create(:bay, :bay_status_id => @bay_status.id, :bay_kind_id => @bay_kind.id)
        expect {post :create, format: :json, :assignment => {:bay_id => bay1.id, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - bay_id not valid" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id + 1, :user_id => @user.id, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
      end

      # --------------- #

      it "should not create record in database - user_id not valid" do
        custom_sign_in @admin
        expect {post :create, format: :json, :assignment => {:bay_id => @bay.id, :user_id => @user.id + 1, :credits_per_hour => 1, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 13.hours}}.to change(Assignment, :count).by(0)
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
end
