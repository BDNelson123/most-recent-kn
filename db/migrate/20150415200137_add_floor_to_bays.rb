class AddFloorToBays < ActiveRecord::Migration
  def change
    add_column :bays, :floor, :integer
  end
end
