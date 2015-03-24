class RenameFeaturesDescriptionToName < ActiveRecord::Migration
  def change
    rename_column :features, :description, :name
  end
end
