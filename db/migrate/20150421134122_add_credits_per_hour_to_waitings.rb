class AddCreditsPerHourToWaitings < ActiveRecord::Migration
  def change
    add_column :waitings, :credits_per_hour, :integer
  end
end
