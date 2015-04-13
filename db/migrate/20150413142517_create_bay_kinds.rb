class CreateBayKinds < ActiveRecord::Migration
  def change
    if !table_exists?("bay_types")
      drop_table :bay_types
    end

    create_table :bay_kinds do |t|
      t.string :name
      t.string :description
      t.integer :credits_per_hour
      t.timestamps null: false
    end
  end
end
