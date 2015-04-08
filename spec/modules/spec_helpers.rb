module SpecHelpers
  def delete_factories
    Admin.destroy_all
    Club.destroy_all
    Course.destroy_all
    Employee.destroy_all
    Feature.destroy_all
    Featurization.destroy_all
    Income.destroy_all
    Level.destroy_all
    Package.destroy_all
    User.destroy_all
  end

  def create_user
    @income = FactoryGirl.create(:income)
    @level = FactoryGirl.create(:level)
    @club = FactoryGirl.create(:club)
    @user = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
  end
end
