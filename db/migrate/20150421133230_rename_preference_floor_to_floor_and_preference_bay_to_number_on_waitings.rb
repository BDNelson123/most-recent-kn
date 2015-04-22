class RenamePreferenceFloorToFloorAndPreferenceBayToNumberOnWaitings < ActiveRecord::Migration
  def change
    rename_column :waitings, :preference_floor, :floor
    rename_column :waitings, :preference_bay, :number
  end
end
