class CreateBayTypes < ActiveRecord::Migration
  def change
    create_table :bay_types do |t|
      t.string :name
      t.string :description
      t.integer :credits_per_hour
      t.timestamps null: false
    end
  end
end
