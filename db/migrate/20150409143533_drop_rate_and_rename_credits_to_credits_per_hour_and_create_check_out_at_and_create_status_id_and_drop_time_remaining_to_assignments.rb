class DropRateAndRenameCreditsToCreditsPerHourAndCreateCheckOutAtAndCreateStatusIdAndDropTimeRemainingToAssignments < ActiveRecord::Migration
  def change
    remove_column :assignments, :rate
    rename_column :assignments, :credits, :credits_per_hour
    add_column :assignments, :check_out_at, :datetime
    add_column :assignments, :status_id, :integer
    remove_column :assignments, :time_remaining
  end
end
