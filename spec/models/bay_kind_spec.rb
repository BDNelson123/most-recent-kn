require 'spec_helper'
include SpecHelpers

describe BayKind do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        bay_kind = FactoryGirl.build(:bay_kind, :name => "test name", :description => "test description", :credits_per_hour => 1)
        bay_kind.should have(0).error_on(:name)
        bay_kind.should have(0).error_on(:description)
        bay_kind.should have(0).error_on(:credits_per_hour)
      end
    end

    context "errors" do
      it "should have one validation error for name presence" do
        bay_kind = FactoryGirl.build(:bay_kind, :name => nil, :description => "test description", :credits_per_hour => 1)
        bay_kind.should have(1).error_on(:name)
      end

      it "should have one validation error for description presence" do
        bay_kind = FactoryGirl.build(:bay_kind, :name => "test name", :description => nil, :credits_per_hour => 1)
        bay_kind.should have(1).error_on(:description)
      end

      it "should have two validation errors for credits_per_hour presence (numeric)" do
        bay_kind = FactoryGirl.build(:bay_kind, :name => "test name", :description => "test description", :credits_per_hour => nil)
        bay_kind.should have(2).error_on(:credits_per_hour)
      end

      it "should have one validation error for credits_per_hour not being integer" do
        bay_kind = FactoryGirl.build(:bay_kind, :name => "test name", :description => "test description", :credits_per_hour => "test credits")
        bay_kind.should have(1).error_on(:credits_per_hour)
      end

      it "should have one validation error for name already being taken" do
        FactoryGirl.create(:bay_kind, :name => "test name", :description => "test description", :credits_per_hour => 1)
        bay_kind = FactoryGirl.build(:bay_kind, :name => "test name", :description => "test description 2")
        bay_kind.should have(1).error_on(:name)
      end
    end
  end
end
