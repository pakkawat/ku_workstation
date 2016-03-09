class RenameAttributeToChefAttribute < ActiveRecord::Migration
  def change
    rename_table :attributes, :chef_attributes
  end
end
