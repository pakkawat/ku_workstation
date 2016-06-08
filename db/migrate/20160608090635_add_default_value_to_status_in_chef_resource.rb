class AddDefaultValueToStatusInChefResource < ActiveRecord::Migration
  def change
    change_column :chef_resources, :status, :string, :default => "install"
  end
end
