class RenameStatusTypeIdToBayStatusIdOnBays < ActiveRecord::Migration
  def change
    rename_column :bays, :status_type_id, :bay_status_id
  end
end
