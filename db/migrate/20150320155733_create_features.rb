class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :description
      t.timestamps null: false
    end
  end
end
