class AddStatusToChefResources < ActiveRecord::Migration
  def change
    add_column :chef_resources, :status, :string
  end
end
