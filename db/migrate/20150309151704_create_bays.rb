class CreateBays < ActiveRecord::Migration
  def change
    create_table :bays do |t|
      t.string :kind
      t.string :state
      t.timestamps null: false
    end
  end
end
