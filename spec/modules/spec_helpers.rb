module SpecHelpers
  def delete_factories
    Admin.destroy_all
    Assignment.destroy_all
    Bay.destroy_all
    BayKind.destroy_all
    BayStatus.destroy_all
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

  def create_user_employee_admin
    @income = FactoryGirl.create(:income)
    @level = FactoryGirl.create(:level)
    @club = FactoryGirl.create(:club)
    @user = FactoryGirl.create(:user, :wood_club_id => @club.id, :iron_club_id => @club.id, :level_id => @level.id, :income_id => @income.id)
    @admin = FactoryGirl.create(:admin)
    @employee = FactoryGirl.create(:employee)
  end

  def create_bay
    @bay_status = FactoryGirl.create(:bay_status)
    @bay_kind = FactoryGirl.create(:bay_kind)
    @bay = FactoryGirl.create(:bay, :bay_status_id => @bay_status.id, :bay_kind_id => @bay_kind.id)
  end

  def create_user_bay
    create_user
    create_bay
  end

  def create_assignment
    create_user_employee_admin
    create_bay
    @assignment = FactoryGirl.create(:assignment, :bay_id => @bay.id, :user_id => @user.id)
  end

  def custom_sign_in(model)
    sign_in model
    request.headers.merge!(model.create_new_auth_token)
  end
end
