class AddRateFloorToBays < ActiveRecord::Migration
  def change
    add_column :bays, :rate, :decimal
    add_column :bays, :floor, :integer
  end
end
