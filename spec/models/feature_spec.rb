require 'spec_helper'

describe Feature do
  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        feature = FactoryGirl.build(:feature, :name => "test features")
        feature.should have(0).error_on(:name)
      end
    end

    context "errors" do
      it "should have one validation error for name presence" do
        feature = FactoryGirl.build(:feature, :name => nil)
        feature.should have(1).error_on(:name)
      end

      it "should have one validation error for name already being taken" do
        FactoryGirl.create(:feature, :name => "test features")
        feature = FactoryGirl.build(:feature, :name => "test features")
        feature.should have(1).error_on(:name)
      end
    end
  end
end
