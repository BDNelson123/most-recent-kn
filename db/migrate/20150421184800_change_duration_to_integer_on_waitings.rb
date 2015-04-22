class ChangeDurationToIntegerOnWaitings < ActiveRecord::Migration
  def change
    change_column :waitings, :duration, :integer
  end
end
