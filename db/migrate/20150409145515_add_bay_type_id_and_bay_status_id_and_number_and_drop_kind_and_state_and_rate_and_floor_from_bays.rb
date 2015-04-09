class AddBayTypeIdAndBayStatusIdAndNumberAndDropKindAndStateAndRateAndFloorFromBays < ActiveRecord::Migration
  def change
    add_column :bays, :bay_type_id, :integer
    add_column :bays, :status_type_id, :integer
    add_column :bays, :number, :string
    remove_column :bays, :kind
    remove_column :bays, :state
    remove_column :bays, :rate
    remove_column :bays, :floor
  end
end
