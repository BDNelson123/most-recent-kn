class ChangeClubsToWoodsAndIronsInUsers < ActiveRecord::Migration
  def change
    remove_column :users, :club_id
    add_column :users, :iron_club_id, :integer
    add_column :users, :wood_club_id, :integer
  end
end
