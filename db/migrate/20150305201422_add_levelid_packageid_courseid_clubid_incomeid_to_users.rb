class AddLevelidPackageidCourseidClubidIncomeidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :level_id, :integer
    add_column :users, :package_id, :integer
    add_column :users, :course_id, :integer
    add_column :users, :club_id, :integer
    add_column :users, :income_id, :integer
  end
end
