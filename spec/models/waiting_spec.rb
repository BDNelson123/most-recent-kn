require 'spec_helper'
include SpecHelpers

describe Waiting do  
  before(:all) do
    create_user_bay
  end

  after(:all) do
    delete_factories
  end

  # --------------------------------------------- #
  # --------------------------------------------- #
  # --------------------------------------------- #

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
        waiting.should have(0).error_on(:bay_id)
        waiting.should have(0).error_on(:user_id)
        waiting.should have(0).error_on(:credits_per_hour)
        waiting.should have(0).error_on(:check_in_at)
        waiting.should have(0).error_on(:check_out_at)
        waiting.should have(0).error_on(:parent_id)
      end

      # --------------- #

      it "should return no validation errors for parent_id" do
        user = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
        parent = FactoryGirl.create(:waiting, :user_id => user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => parent.id, :credits_per_hour => 1, :duration => 90)
        waiting.should have(0).error_on(:bay_id)
        waiting.should have(0).error_on(:user_id)
        waiting.should have(0).error_on(:credits_per_hour)
        waiting.should have(0).error_on(:check_in_at)
        waiting.should have(0).error_on(:check_out_at)
        waiting.should have(0).error_on(:parent_id)
      end
    end

    # ------------------------------ #
    # ------------------------------ #

    context "errors" do
      context "user_id" do
        it "should return 1 error for user_id blank" do
          waiting = FactoryGirl.build(:waiting, :user_id => nil, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
          waiting.should have(1).error_on(:user_id)
        end

        # --------------- #

        it "should return 1 error for user_id not valid" do
          waiting = FactoryGirl.build(:waiting, :user_id => @user.id + 1, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
          waiting.should have(1).error_on(:user_id)
        end

        # --------------- #

        it "should return 1 error for user_id not being unique" do
          FactoryGirl.create(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
          waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
          waiting.should have(1).error_on(:user_id)
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      context "bay_kind_id" do
        it "should return 1 error for bay_kind_id being blank" do
          waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => nil, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
          waiting.should have(1).error_on(:bay_kind_id)
        end

        # --------------- #

        it "should return 1 error for bay_kind_id not being valid" do
          waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id + 1, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
          waiting.should have(1).error_on(:bay_kind_id)
        end
      end

      # ------------------------------ #
      # ------------------------------ #

      it "should return 1 error for floor not present if number is present" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => nil, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
        waiting.should have(1).error_on(:floor)
      end

      # --------------- #

      it "should return 1 error for number if number does not exist on floor" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number.to_i + 1, :parent_id => nil, :credits_per_hour => 1, :duration => 90)
        waiting.should have(1).error_on(:number)
      end

      # --------------- #

      it "should return 1 error for duration if not present" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => nil)
        waiting.should have(1).error_on(:duration)
      end

      it "should return 1 error for duration if not a number" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => 1, :duration => "test")
        waiting.should have(1).error_on(:duration)
      end

      # --------------- #

      it "should return 1 error for credits_per_hour if not present" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => nil, :duration => 90)
        waiting.should have(1).error_on(:credits_per_hour)
      end

      # --------------- #

      it "should return 1 error for credits_per_hour if not a number" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => nil, :credits_per_hour => "test", :duration => 90)
        waiting.should have(1).error_on(:credits_per_hour)
      end

      # --------------- #

      it "should return 1 error for parent_id not being valid" do
        waiting = FactoryGirl.build(:waiting, :user_id => @user.id, :bay_kind_id => @bay_kind.id, :floor => @bay.floor, :number => @bay.number, :parent_id => 1, :credits_per_hour => 1, :duration => 90)
        waiting.should have(1).error_on(:parent_id)
      end
    end
  end
end
