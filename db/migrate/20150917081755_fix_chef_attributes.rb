class FixChefAttributes < ActiveRecord::Migration
  def change
    rename_column :chef_attributes, :type, :att_type
  end
end
