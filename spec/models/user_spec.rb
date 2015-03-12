require 'spec_helper'

describe User do
  # building the club objects needed for testing
  before(:all) do
    @club1 = FactoryGirl.create(:club)
    @club2 = FactoryGirl.create(:club, :name => "Adams Golf")
    @level = FactoryGirl.create(:level)
    @income = FactoryGirl.create(:income)
  end

  # destroying the club objects after tests run
  after(:all) do
    Club.destroy_all
    Level.destroy_all
    Income.destroy_all
    User.destroy_all
  end

  context "validations" do
    context "no errors" do
      context "address2 present" do
        it "should return zero validation errors" do
          user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
          user.should have(0).error_on(:name)
          user.should have(0).error_on(:address)
          user.should have(0).error_on(:address2)
          user.should have(0).error_on(:city)
          user.should have(0).error_on(:state)
          user.should have(0).error_on(:zip)
          user.should have(0).error_on(:phone)
          user.should have(0).error_on(:dob)
          user.should have(0).error_on(:handedness)
          user.should have(0).error_on(:owns_clubs)
          user.should have(0).error_on(:iron_club_id)
          user.should have(0).error_on(:wood_club_id)
          user.should have(0).error_on(:gender)
          user.should have(0).error_on(:email)
          user.should have(0).error_on(:level_id)
          user.should have(0).error_on(:income_id)
          user.should have(0).error_on(:email_optin)
          user.should have(0).error_on(:terms_accepted)
          user.should have(0).error_on(:password)
          user.should have(0).error_on(:password_confirmation)
        end
      end
    end

    context "address" do
      it "should return an error if address is not present" do
        user = FactoryGirl.build(:user, :address => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:address)
      end
    end

    context "address2" do
      it "should not return  an error if address2 is not present" do
        user = FactoryGirl.create(:user, :address2 => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:address2)
      end
    end

    context "city" do
      it "should return an error if city is not present" do
        user = FactoryGirl.build(:user, :city => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:city)
      end
    end

    context "state" do
      it "should return  an error if state is not present" do
        user = FactoryGirl.build(:user, :state => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:state)
      end
    end

    context "Zip" do
      it "should return  an error if zip is not present" do
        user = FactoryGirl.build(:user, :zip => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:zip)
      end
    end

    context "Phone" do
      it "should return 2 errors if phone is not present for presence, numerical, and minimum length" do
        user = FactoryGirl.build(:user, :phone => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(3).error_on(:phone)
      end

      it "should return 1 error if phone is not numerical" do
        user = FactoryGirl.build(:user, :phone => "32ad3232as", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:phone)
      end

      it "should return 1 error if phone if its greater than 15 characters" do
        user = FactoryGirl.build(:user, :phone => "123242342343213123123123123123", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:phone)
      end

      it "should return 1 error if phone is and integer but less than 10 characters long" do
        user = FactoryGirl.build(:user, :phone => "123123", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:phone)
      end
    end

    context "dob" do
      it "should return one error if the person is not 18 years old yet" do
        user = FactoryGirl.build(:user, :dob => "1-1-2010", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:dob)
      end

      it "should return 2 errors if dob is not present - not present and validates_date when user was born" do
        user = FactoryGirl.build(:user, :dob => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(2).error_on(:dob)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "handedness" do
      it "should return one error if handedness is not present" do
        user = FactoryGirl.build(:user, :handedness => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:handedness)
      end

      it "should return no errors if handedness equals true" do
        user = FactoryGirl.build(:user, :handedness => true, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:handedness)
      end

      it "should return no errors if handedness equals false" do
        user = FactoryGirl.build(:user, :handedness => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:handedness)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "gender" do
      it "should return one error if gender is not present" do
        user = FactoryGirl.build(:user, :gender => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:gender)
      end

      it "should return no errors if handedness equals true" do
        user = FactoryGirl.build(:user, :gender => true, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:gender)
      end

      it "should return no errors if handedness equals false" do
        user = FactoryGirl.build(:user, :gender => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:gender)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "owns_clubs" do
      it "should return one error if owns_clubs is not present" do
        user = FactoryGirl.build(:user, :owns_clubs => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:owns_clubs)
      end

      it "should return no errors if owns_clubs equals true" do
        user = FactoryGirl.build(:user, :owns_clubs => true, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:owns_clubs)
      end

      it "should return no errors if owns_clubs equals false" do
        user = FactoryGirl.build(:user, :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:owns_clubs)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "email_optin" do
      it "should return one error if email_optin is not present" do
        user = FactoryGirl.build(:user, :email_optin => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:email_optin)
      end

      it "should return no errors if email_optin equals true" do
        user = FactoryGirl.build(:user, :email_optin => true, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:email_optin)
      end

      it "should return no errors if email_optin equals false" do
        user = FactoryGirl.build(:user, :email_optin => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:email_optin)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "terms_accepted" do
      it "should return one error if terms_accepted is not present" do
        user = FactoryGirl.build(:user, :terms_accepted => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:terms_accepted)
      end

      it "should return no errors if terms_accepted equals true" do
        user = FactoryGirl.build(:user, :terms_accepted => true, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:terms_accepted)
      end

      it "should return no errors if terms_accepted equals false" do
        user = FactoryGirl.build(:user, :terms_accepted => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(0).error_on(:terms_accepted)
      end
    end

    context "iron_club_id" do
      it "should return two errors if iron_club_id is not present - presence = true, and include_wood_id" do
        user = FactoryGirl.build(:user, :iron_club_id => nil, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(2).error_on(:iron_club_id)
      end

      it "should return one error if iron_club_id is not in the Club object" do
        user = FactoryGirl.build(:user, :iron_club_id => 12312312, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:iron_club_id)
      end
    end

    context "level_id" do
      it "should return two errors if level_id is not present - presence = true, and include_wood_id" do
        user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => nil, :income_id => @income.id)
        user.should have(2).error_on(:level_id)
      end

      it "should return one error if level_id is not in the Level object" do
        user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => 12312312, :income_id => @income.id)
        user.should have(1).error_on(:level_id)
      end
    end

    context "income_id" do
      it "should return two errors if income_id is not present - presence = true, and income_id custom validation" do
        user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => nil)
        user.should have(2).error_on(:income_id)
      end

      it "should return one error if income_id is not in the Income object" do
        user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => 12312312)
        user.should have(1).error_on(:income_id)
      end
    end

    context "wood_club_id" do
      it "should return two errors if wood_club_id is not present - presence = true, and include_wood_id" do
        user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => nil, :level_id => @level.id, :income_id => @income.id)
        user.should have(2).error_on(:wood_club_id)
      end

      it "should return one error if wood_club_id is not in the Club object" do
        user = FactoryGirl.build(:user, :iron_club_id => @club1.id, :wood_club_id => 12312312, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:wood_club_id)
      end
    end

    context "email" do
      it "should return three errors if email is not present - presence = true, validates email format, uniqueness of email" do
        user = FactoryGirl.build(:user, :email => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(3).error_on(:email)
      end

      it "should return one error if email is not correct format" do
        user = FactoryGirl.build(:user, :email => "test.com", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:email)
      end

      it "should return one error if email has already been taken" do
        user1 = FactoryGirl.create(:user, :email => "test@test.com", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user2 = FactoryGirl.build(:user, :email => user1.email, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user2.should have(1).error_on(:email)
        user1.destroy
      end
    end

    context "password" do
      it "should return two errors if password is not present - password cant be nil and password doesn't match password_confirmation" do
        user = FactoryGirl.build(:user, :password => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:password)
        user.should have(1).error_on(:password_confirmation)
      end

      it "should return one error if password does not equal password_confirmation" do
        user = FactoryGirl.build(:user, :password => "test12345", :password_confirmation => "test1234", :iron_club_id => @club1.id, :wood_club_id => @club2.id, :level_id => @level.id, :income_id => @income.id)
        user.should have(1).error_on(:password_confirmation)
      end
    end
  end
end
