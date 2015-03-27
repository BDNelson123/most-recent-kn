require 'spec_helper'
include SpecHelpers

describe Level do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        level = FactoryGirl.build(:level, :name => "test levels")
        level.should have(0).error_on(:name)
      end
    end

    context "errors" do
      it "should have one validation error for name presence" do
        level = FactoryGirl.build(:level, :name => nil)
        level.should have(1).error_on(:name)
      end

      it "should have one validation error for name already being taken" do
        FactoryGirl.create(:level, :name => "test levels")
        level = FactoryGirl.build(:level, :name => "test levels")
        level.should have(1).error_on(:name)
      end

      it "should have one validation error for handicap presence" do
        level = FactoryGirl.build(:level, :handicap => nil)
        level.should have(1).error_on(:handicap)
      end

      it "should have one validation error for description presence" do
        level = FactoryGirl.build(:level, :description => nil)
        level.should have(1).error_on(:description)
      end
    end
  end
end
