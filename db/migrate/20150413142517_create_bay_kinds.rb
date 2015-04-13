class CreateBayKinds < ActiveRecord::Migration
  def change
    drop_table :bay_types

    create_table :bay_kinds do |t|
      t.string :name
      t.string :description
      t.integer :credits_per_hour
      t.timestamps null: false
    end
  end
end
