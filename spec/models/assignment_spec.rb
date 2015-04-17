require 'spec_helper'
include SpecHelpers

describe Assignment do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        assignment.should have(0).error_on(:bay_id)
        assignment.should have(0).error_on(:user_id)
        assignment.should have(0).error_on(:credits_per_hour)
        assignment.should have(0).error_on(:check_in_at)
        assignment.should have(0).error_on(:check_out_at)
        assignment.should have(0).error_on(:parent_id)
      end

      it "should return no validation errors for parent_id" do
        create_user_bay
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        assignment2 = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :parent_id => assignment1.id)
        assignment2.should have(0).error_on(:parent_id)
      end
    end

    context "errors" do
      it "should return two errors for bay presence and valid bay" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => nil, :user_id => @user.id)
        assignment.should have(2).error_on(:bay_id)
      end

      it "should return one error for credits_per_hour presence" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :credits_per_hour => nil)
        assignment.should have(1).error_on(:credits_per_hour)
      end

      it "should return one error for check_in_at presence" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_in_at => nil)
        assignment.should have(1).error_on(:check_in_at)
      end

      it "should return one error for check_out_at presence" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_out_at => nil)
        assignment.should have(1).error_on(:check_out_at)
      end

      it "should return one error for bay_id uniqueness" do
        create_user_bay
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        assignment2 = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        assignment2.should have(1).error_on(:bay_id)
      end

      it "should return one error for user_id uniqueness" do
        create_user_bay
        assignment1 = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        assignment2 = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id)
        assignment2.should have(1).error_on(:user_id)
      end

      it "should return one error for bay_id not being valid" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id + 1, :user_id => @user.id)
        assignment.should have(1).error_on(:bay_id)
      end

      it "should return one error for user_id not being valid" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id + 1)
        assignment.should have(1).error_on(:user_id)
      end

      it "should return one error for parent_id not being valid" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :parent_id => 1)
        assignment.should have(1).error_on(:parent_id)
      end

      it "should return one error for check_in_at being after check_out_at" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 11.hours)
        assignment.should have(1).error_on(:check_out_at)
      end

      it "should return one error for check_in_at being at same time as check_out_at" do
        create_user_bay
        time = DateTime.now + 12.hours
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_in_at => time, :check_out_at => time)
        assignment.should have(1).error_on(:check_out_at)
      end

      it "should return one error for check_out_at being more than 12 hours after check_in_at" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_in_at => DateTime.now + 12.hours, :check_out_at => DateTime.now + 25.hours)
        assignment.should have(1).error_on(:check_out_at)
      end

      it "should return one error for check_in_at being more than one hour in the past" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_in_at => DateTime.now - 2.hours)
        assignment.should have(1).error_on(:check_in_at)
      end

      it "should return one error for check_out_at being in the past" do
        create_user_bay
        assignment = FactoryGirl.build(:assignment, :bay_id => @bay.id, :user_id => @user.id, :check_in_at => DateTime.now - 30.minutes, :check_out_at => DateTime.now - 20.minutes)
        assignment.should have(1).error_on(:check_out_at)
      end
    end
  end
end
