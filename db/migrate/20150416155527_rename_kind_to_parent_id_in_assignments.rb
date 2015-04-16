class RenameKindToParentIdInAssignments < ActiveRecord::Migration
  def change
    rename_column :assignments, :kind, :parent_id
  end
end
