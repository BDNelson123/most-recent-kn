class RenameBayTypeIdToBayKindIdInBays < ActiveRecord::Migration
  def change
    rename_column :bays, :bay_type_id, :bay_kind_id
  end
end
