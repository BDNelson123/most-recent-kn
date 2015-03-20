class CreateFeaturizations < ActiveRecord::Migration
  def change
    create_table :featurizations do |t|
      t.integer :package_id
      t.integer :feature_id
      t.timestamps null: false
    end
  end
end
