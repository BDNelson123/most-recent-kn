class AddDurationToWaitings < ActiveRecord::Migration
  def change
    add_column :waitings, :duration, :time
  end
end
