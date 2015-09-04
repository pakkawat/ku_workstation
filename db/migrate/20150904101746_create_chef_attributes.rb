class CreateChefAttributes < ActiveRecord::Migration
  def change
    create_table :chef_attributes do |t|
      t.string :att_value
      t.string :type
      t.references :chef_resource, index: true

    end
    add_foreign_key :chef_attributes, :chef_resources
  end
end
