class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.integer :zip
      t.timestamps null: false
    end
  end
end
