class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.integer :user_id
      t.integer :bay_id
      t.integer :parent_id
      t.datetime :check_in_at
      t.datetime :check_out_at

      t.timestamps null: false
    end
  end
end
