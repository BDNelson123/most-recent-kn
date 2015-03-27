require 'spec_helper'

describe Course do
  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        course = FactoryGirl.build(:course)
        course.should have(0).error_on(:name)
        course.should have(0).error_on(:address)
        course.should have(0).error_on(:address2)
        course.should have(0).error_on(:city)
        course.should have(0).error_on(:state)
        course.should have(0).error_on(:zip)
      end

      it "should return no validation errors when address2 is nil" do
        course = FactoryGirl.build(:course, :address2 => nil)
        course.should have(0).error_on(:address2)
      end
    end

    context "errors" do
      it "should return one error when name is nil" do
        course = FactoryGirl.build(:course, :name => nil)
        course.should have(1).error_on(:name)
      end

      it "should return one error when address is nil" do
        course = FactoryGirl.build(:course, :address => nil)
        course.should have(1).error_on(:address)
      end

      it "should return one error when city is nil" do
        course = FactoryGirl.build(:course, :city => nil)
        course.should have(1).error_on(:city)
      end

      it "should return one error when state is nil" do
        course = FactoryGirl.build(:course, :state => nil)
        course.should have(1).error_on(:state)
      end

      it "should return one error when zip is nil" do
        course = FactoryGirl.build(:course, :zip => nil)
        course.should have(1).error_on(:zip)
      end
    end
  end
end
