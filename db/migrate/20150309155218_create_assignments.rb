class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :bay_id
      t.integer :user_id
      t.decimal :rate
      t.integer :credits
      t.datetime :check_in_at
      t.time :time_remaining
      t.timestamps null: false
    end
  end
end
