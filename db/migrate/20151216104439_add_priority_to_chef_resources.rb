class AddPriorityToChefResources < ActiveRecord::Migration
  def change
    add_column :chef_resources, :priority, :integer
  end
end
