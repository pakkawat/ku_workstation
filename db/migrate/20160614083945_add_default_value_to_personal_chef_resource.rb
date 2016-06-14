class AddDefaultValueToPersonalChefResource < ActiveRecord::Migration
  def change
    change_column :personal_chef_resources, :status, :string, :default => "install"
  end
end
