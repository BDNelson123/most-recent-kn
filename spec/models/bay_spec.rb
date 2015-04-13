require 'spec_helper'
include SpecHelpers

describe Bay do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        bay_status = FactoryGirl.create(:bay_status)
        bay_kind = FactoryGirl.create(:bay_kind)
        bay = FactoryGirl.build(:bay, :bay_status_id => bay_status.id, :bay_kind_id => bay_kind.id)
        bay.should have(0).error_on(:bay_kind_id)
        bay.should have(0).error_on(:bay_status_id)
        bay.should have(0).error_on(:number)
      end
    end

    context "errors" do
      it "should have two validation errors for bay_status_id presence (valid bay_status_id)" do
        bay_kind = FactoryGirl.create(:bay_kind)
        bay = FactoryGirl.build(:bay, :bay_status_id => nil, :bay_kind_id => bay_kind.id)
        bay.should have(2).error_on(:bay_status_id)
      end

      it "should have one validation erros for bay_status_id valid bay_status_id" do
        bay_kind = FactoryGirl.create(:bay_kind)
        bay = FactoryGirl.build(:bay, :bay_status_id => 1, :bay_kind_id => bay_kind.id)
        bay.should have(1).error_on(:bay_status_id)
      end

      it "should have two validation errors for bay_kind_id presence (valid bay_kind_id)" do
        bay_status = FactoryGirl.create(:bay_status)
        bay = FactoryGirl.build(:bay, :bay_status_id => bay_status.id, :bay_kind_id => nil)
        bay.should have(2).error_on(:bay_kind_id)
      end

      it "should have one validation erros for bay_kind_id valid bay_kind_id" do
        bay_status = FactoryGirl.create(:bay_status)
        bay = FactoryGirl.build(:bay, :bay_status_id => bay_status.id, :bay_kind_id => 1)
        bay.should have(1).error_on(:bay_kind_id)
      end

      it "should have one validation error for number presence" do
        bay = FactoryGirl.build(:bay, :number => nil)
        bay.should have(1).error_on(:number)
      end

      it "should have one validation error for number already being taken" do
        bay_status = FactoryGirl.create(:bay_status)
        bay_kind = FactoryGirl.create(:bay_kind)
        bay1 = FactoryGirl.create(:bay, :bay_status_id => bay_status.id, :bay_kind_id => bay_kind.id)
        bay2 = FactoryGirl.build(:bay, :bay_status_id => bay_status.id, :bay_kind_id => bay_kind.id, :number => bay1.number)
        bay2.should have(1).error_on(:number)
      end
    end
  end
end
