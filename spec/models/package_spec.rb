require 'spec_helper'

describe Package do
  context "validations" do
    context "no errors" do
      it "should return no validation errors" do
        package = FactoryGirl.build(:package)
        package.should have(0).error_on(:name)
        package.should have(0).error_on(:description)
        package.should have(0).error_on(:price)
        package.should have(0).error_on(:credits)
      end

      it "should return no validation errors on price for decimal" do
        package = FactoryGirl.build(:package, :price => "22.9")
        package.should have(0).error_on(:price)
      end
    end

    context "errors" do
      it "should return one error when name is nil" do
        package = FactoryGirl.build(:package, :name => nil)
        package.should have(1).error_on(:name)
      end

      it "should return one error when description is nil" do
        package = FactoryGirl.build(:package, :description => nil)
        package.should have(1).error_on(:description)
      end

      # number and nil errors
      it "should return one error when price is nil" do
        package = FactoryGirl.build(:package, :price => nil)
        package.should have(2).error_on(:price)
      end

      # number and nil errors
      it "should return one error when credits is nil" do
        package = FactoryGirl.build(:package, :credits => nil)
        package.should have(2).error_on(:credits)
      end

      it "should return none validation error on price being not numeric" do
        package = FactoryGirl.build(:package, :price => "test")
        package.should have(1).error_on(:price)
      end

      it "should return none validation error on credits being not numeric" do
        package = FactoryGirl.build(:package, :credits => "test")
        package.should have(1).error_on(:credits)
      end
    end
  end
end
