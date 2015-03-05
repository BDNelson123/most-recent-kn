class CreateIncomes < ActiveRecord::Migration
  def change
    create_table :incomes do |t|
      t.string :name
      t.string :description
      t.timestamps null: false
    end
  end
end
