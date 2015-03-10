require 'spec_helper'

describe User do
  # building the club objects needed for testing
  before(:all) do
    @club1 = FactoryGirl.create(:club)
    @club2 = FactoryGirl.create(:club, :name => "Adams Golf")
  end

  # destroying the club objects after tests run
  after(:all) do
    Club.destroy_all
    User.destroy_all
  end

  context "validations" do
    context "no validation errors" do
      context "address2 present" do
        it "should return zero validation errors" do
          user = User.new(
            :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
            :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
            :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
            :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
            :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
          )
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
          user.should have(0).error_on(:password)
          user.should have(0).error_on(:password_confirmation)
        end
      end
    end

    context "address validations" do
      it "should return an error if address is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => nil, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:address)
      end
    end

    context "address2 validations" do
      it "should not return  an error if address2 is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => nil, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:address2)
      end
    end

    context "city validations" do
      it "should return  an error if city is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => nil, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:city)
      end
    end

    context "state validations" do
      it "should return  an error if state is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => nil, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:state)
      end
    end

    context "Zip validations" do
      it "should return  an error if zip is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => nil,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:zip)
      end
    end

    context "Phone validations" do
      it "should return 2 errors if phone is not present for presence, numerical, and minimum length" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => nil, :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(3).error_on(:phone)
      end

      it "should return 1 error if phone is not numerical" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "32ad3232as", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:phone)
      end

      it "should return 1 error if phone if its greater than 15 characters" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "123242342343213123123123123123", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:phone)
      end

      it "should return 1 error if phone is and integer but less than 10 characters long" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "123123", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:phone)
      end
    end

    context "dob validations" do
      it "should return one error if the person is not 18 years old yet" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-2010", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:dob)
      end

      it "should return 2 errors if dob is not present - not present and validates_date when user was born" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => nil, :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(2).error_on(:dob)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "handedness validations" do
      it "should return one error if handedness is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => nil,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:handedness)
      end

      it "should return no errors if handedness equals true" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:handedness)
      end

      it "should return no errors if handedness equals false" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => false,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:handedness)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "gender validations" do
      it "should return one error if gender is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => nil, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:gender)
      end

      it "should return no errors if handedness equals true" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => true, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:gender)
      end

      it "should return no errors if handedness equals false" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:gender)
      end
    end

    # cant test anything but true/false due to mysql field being boolean, so will only test not being present and true/false
    context "owns_clubs validations" do
      it "should return one error if owns_clubs is not present" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => nil, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => true, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:owns_clubs)
      end

      it "should return no errors if handedness equals true" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => true, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => true, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:owns_clubs)
      end

      it "should return no errors if handedness equals false" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => true, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(0).error_on(:owns_clubs)
      end
    end

    context "iron_club_id validations" do
      it "should return two errors if iron_club_id is not present - presence = true, and include_wood_id" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => nil, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(2).error_on(:iron_club_id)
      end

      it "should return one error if iron_club_id is not in the Club object" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => 12312312, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:iron_club_id)
      end
    end

    context "wood_club_id validations" do
      it "should return two errors if wood_club_id is not present - presence = true, and include_wood_id" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => nil,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(2).error_on(:wood_club_id)
      end

      it "should return one error if wood_club_id is not in the Club object" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => 12312312,
          :gender => false, :email => Faker::Internet.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:wood_club_id)
      end
    end

    context "email validations" do
      it "should return two errors if email is not present - presence = true, and validates email format" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => nil, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(2).error_on(:email)
      end

      it "should return one error if email is not correct format" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => "test.com", :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:email)
      end

      it "should return one error if email has already been taken" do
        user = FactoryGirl.create(:user, :iron_club_id => @club1.id, :wood_club_id => @club2.id)

        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => user.email, :password => "test1234", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:email)
      end
    end

    context "password validations" do
      it "should return two errors if password is not present - password cant be nil and password doesn't match password_confirmation" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => nil, :password_confirmation => "test1234"
        )
        user.should have(2).error_on(:password)
      end

      it "should return one error if password does not equal password_confirmation" do
        user = User.new(
          :name => Faker::Name.name, :address => Faker::Address.street_address, :address2 => Faker::Address.secondary_address, 
          :city => Faker::Address.city, :state => Faker::Address.state_abbr, :zip => Faker::Address.zip,
          :phone => "18067770259", :dob => "1-1-1985", :handedness => true,
          :owns_clubs => false, :iron_club_id => @club1.id, :wood_club_id => @club2.id,
          :gender => false, :email => Faker::Internet.email, :password => "test12345", :password_confirmation => "test1234"
        )
        user.should have(1).error_on(:password_confirmation)
      end
    end
  end
end
