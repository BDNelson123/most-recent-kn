class CreateWaitings < ActiveRecord::Migration
  def change
    create_table :waitings do |t|
      t.integer :user_id
      t.integer :bay_kind_id
      t.integer :preference_floor
      t.integer :preference_bay

      t.timestamps null: false
    end
  end
end
