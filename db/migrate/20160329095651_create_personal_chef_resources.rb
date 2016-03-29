class CreatePersonalChefResources < ActiveRecord::Migration
  def change
    create_table :personal_chef_resources do |t|
      t.string :resource_type
      t.integer :priority

      t.timestamps null: false
    end
  end
end
