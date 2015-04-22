require 'spec_helper'
include Devise::TestHelpers
include SpecHelpers

describe V1::BaysController do
  before(:each) do
    # create main user
    @income = FactoryGirl.create(:income)
    @level = FactoryGirl.create(:level)
    @club = FactoryGirl.create(:club)
    @user = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)

    # create admin and employee
    @admin = FactoryGirl.create(:admin)
    @employee = FactoryGirl.create(:employee)

    # create assignment1
    @user1 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @bay_status1 = FactoryGirl.create(:bay_status, :id => 1)
    @bay_kind1 = FactoryGirl.create(:bay_kind)
    @bay1 = FactoryGirl.create(:bay, :bay_status_id => @bay_status1.id, :bay_kind_id => @bay_kind1.id)
    @assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay1.id, :user_id => @user1.id)

    # create assignment2
    @user2 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @bay_status2 = FactoryGirl.create(:bay_status, :id => 2)
    @bay_kind2 = FactoryGirl.create(:bay_kind)
    @bay2 = FactoryGirl.create(:bay, :bay_status_id => @bay_status2.id, :bay_kind_id => @bay_kind2.id)
    @assignment2 = FactoryGirl.create(:assignment, :bay_id => @bay2.id, :user_id => @user2.id)

    # create assignment3
    @user3 = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @bay_status3 = FactoryGirl.create(:bay_status, :id => 3)
    @bay_kind3 = FactoryGirl.create(:bay_kind)
    @bay3 = FactoryGirl.create(:bay, :bay_status_id => @bay_status3.id, :bay_kind_id => @bay_kind3.id)
    @assignment3 = FactoryGirl.create(:assignment, :bay_id => @bay3.id, :user_id => @user3.id)

    # additional bay_statuses for testing bay status 5
    @bay_status4 = FactoryGirl.create(:bay_status, :id => 4)
    @bay_status5 = FactoryGirl.create(:bay_status, :id => 5)

    # create test user we are going to play with - he has not been put into an assignment
    @user_test = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @waiting = FactoryGirl.create(:waiting, :user_id => @user_test.id, :bay_kind_id => @bay_kind3.id)
  end

  after(:each) do
    delete_factories
  end

  # UPDATE action tests
  # Scenario:
  # 3 assignments have been created with 3 different bays and 3 different bay_kinds
  # 1 user has been created that has been put into the waiting list, he is waiting for bay_kind_3 to open up
  # we are deleting the assignment for for bay3, changing its status to bussing
  describe "#update" do
    context "authentication" do
      it "should return a status of 401 and body of authorized users only for user" do
        custom_sign_in @user
        put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => @bay3.bay_status_id}
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['errors'].to_s).to include("Authorized users only.")
      end

      it "should return a status of 200 for employee" do
        custom_sign_in @employee
        put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => @bay3.bay_status_id}
        expect(response.body).to include("data")
        expect(response.status).to eq(200)
      end

      it "should return a status of 200 for admin" do
        custom_sign_in @admin
        put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => @bay3.bay_status_id}
        expect(response.body).to include("data")
        expect(response.status).to eq(200)
      end
    end

    context "bay_status_id == 2" do
      context "assignment records" do
        it "should not create a new assignment since bay_status_id is not 2" do
          custom_sign_in @admin
          @assignment3.destroy
          expect {put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => @bay3.bay_status_id}}.to change(Assignment, :count).by(0)
        end

        it "should create a new assignment since bay_status_id is changed to 2" do
          custom_sign_in @admin
          @assignment3.destroy
          expect {put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => 2}}.to change(Assignment, :count).by(1)
        end
      end

      context "waiting records" do
        it "should not create a new assignment since bay_status_id is not 2" do
          custom_sign_in @admin
          @assignment3.destroy
          expect {put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => @bay3.bay_status_id}}.to change(Waiting, :count).by(0)
        end

        it "should create a new assignment since bay_status_id is changed to 2" do
          custom_sign_in @admin
          @assignment3.destroy
          expect {put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => 2}}.to change(Waiting, :count).by(-1)
        end
      end
    end

    context "bay_status_id == 5" do
      context "assignment records" do
        it "should not delete assignment of bay since bay_status_id is not 5" do
          custom_sign_in @admin
          expect {put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => 4}}.to change(Assignment, :count).by(0)
        end

        it "should delete assignment of bay since bay_status_id is 5" do
          custom_sign_in @admin
          expect {put :update, format: :json, :id => @bay3.id, :bay => {:bay_status_id => 5}}.to change(Assignment, :count).by(-1)
        end
      end
    end
  end
end
