class UpdateChef < ActiveRecord::Migration
  def change
    drop_table :program_chefs

    create_table :program_chefs do |t|
      t.belongs_to :program, index: true
      t.belongs_to :chef_resource, index: true
      t.timestamps null: false
    end

    drop_table :chef_properties

    create_table :chef_properties do |t|
      t.string :value
      t.string :value_type
      t.references :chef_resource, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
