class DropBayType < ActiveRecord::Migration
  def up
    drop_table 'bay_types' if ActiveRecord::Base.connection.table_exists? 'bay_types'
  end
end
