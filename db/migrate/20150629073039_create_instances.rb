class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :instance_name
      t.string :instance_id2
      t.string :instance_type
      t.string :public_dns
      t.string :public_ip

      t.timestamps null: false
    end
  end
end
