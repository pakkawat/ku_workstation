class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.string :name
      t.references :chef_property, index: true

      t.timestamps null: false
    end
    add_foreign_key :attributes, :chef_properties
  end
end
