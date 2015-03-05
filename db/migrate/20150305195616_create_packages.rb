class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.string :description
      t.string :features
      t.decimal :price, :precision => 8, :scale => 2
      t.timestamps null: false
    end
  end
end
