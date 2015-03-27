require 'spec_helper'
include SpecHelpers

describe Club do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        club = FactoryGirl.build(:club, :name => "test clubs")
        club.should have(0).error_on(:name)
      end
    end

    context "errors" do
      it "should have one validation error for name presence" do
        club = FactoryGirl.build(:club, :name => nil)
        club.should have(1).error_on(:name)
      end

      it "should have one validation error for name already being taken" do
        FactoryGirl.create(:club, :name => "test clubs")
        club = FactoryGirl.build(:club, :name => "test clubs")
        club.should have(1).error_on(:name)
      end
    end
  end
end
