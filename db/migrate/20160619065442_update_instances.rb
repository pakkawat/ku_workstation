class UpdateInstances < ActiveRecord::Migration
  def change
    remove_column :instances, :instance_name, :string
    remove_column :instances, :instance_id2, :string
    remove_column :instances, :instance_type, :string
    remove_column :instances, :public_dns, :string
    remove_column :instances, :public_ip, :string

    add_column :instances, :uptime_seconds, :bigint
    add_column :instances, :network_tx, :bigint
  end
end
