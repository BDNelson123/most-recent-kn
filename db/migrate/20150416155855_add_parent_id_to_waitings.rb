class AddParentIdToWaitings < ActiveRecord::Migration
  def change
    add_column :waitings, :parent_id, :integer
  end
end
