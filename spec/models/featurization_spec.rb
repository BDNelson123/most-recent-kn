require 'spec_helper'
include SpecHelpers

describe Featurization do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        feature = FactoryGirl.create(:feature)
        featurization = FactoryGirl.build(:featurization, :feature_id => feature.id)
        featurization.should have(0).error_on(:feature_id)
      end
    end

    context "errors" do
      it "should return one validation error for feature_id not existing in Feature model" do
        featurization = FactoryGirl.build(:featurization)
        featurization.should have(1).error_on(:feature_id)
      end

      it "should have three validation errors for feature_id presence / not existing in Feature model / not being an integer" do
        featurization = FactoryGirl.build(:featurization, :feature_id => nil)
        featurization.should have(3).error_on(:feature_id)
      end
    end
  end
end
