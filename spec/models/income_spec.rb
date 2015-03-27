require 'spec_helper'
include SpecHelpers

describe Income do
  after(:each) do
    delete_factories
  end

  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        income = FactoryGirl.build(:income, :name => "test incomes")
        income.should have(0).error_on(:name)
      end
    end

    context "errors" do
      it "should have one validation error for name presence" do
        income = FactoryGirl.build(:income, :name => nil)
        income.should have(1).error_on(:name)
      end

      it "should have one validation error for name already being taken" do
        FactoryGirl.create(:income, :name => "test incomes")
        income = FactoryGirl.build(:income, :name => "test incomes")
        income.should have(1).error_on(:name)
      end
    end
  end
end
