require 'spec_helper'
include SpecHelpers

describe BayStatus do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        bay_status = FactoryGirl.build(:bay_status, :name => "test name", :description => "test description")
        bay_status.should have(0).error_on(:name)
        bay_status.should have(0).error_on(:description)
      end
    end

    context "errors" do
      it "should have one validation error for name presence" do
        bay_status = FactoryGirl.build(:bay_status, :name => nil, :description => "test description")
        bay_status.should have(1).error_on(:name)
      end

      it "should have one validation error for description presence" do
        bay_status = FactoryGirl.build(:bay_status, :name => "test name", :description => nil)
        bay_status.should have(1).error_on(:description)
      end

      it "should have one validation error for name already being taken" do
        FactoryGirl.create(:bay_status, :name => "test name", :description => "test description")
        bay_status = FactoryGirl.build(:bay_status, :name => "test name", :description => "test description 2")
        bay_status.should have(1).error_on(:name)
      end
    end
  end
end
