class ChangeLevelsHandicapToString < ActiveRecord::Migration
  def change
    change_column :levels, :handicap, :string
  end
end
