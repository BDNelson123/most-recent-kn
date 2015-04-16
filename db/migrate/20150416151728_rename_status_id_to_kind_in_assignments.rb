class RenameStatusIdToKindInAssignments < ActiveRecord::Migration
  def change
    rename_column :assignments, :status_id, :kind
  end
end
