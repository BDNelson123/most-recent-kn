class AddCreditsAndRemoveFeaturesFromPackages < ActiveRecord::Migration
  def change
    add_column :packages, :credits, :integer
    remove_column :packages, :features
  end
end
