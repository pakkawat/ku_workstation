class CreateChefResources < ActiveRecord::Migration
  def change
    create_table :chef_resources do |t|
      t.string :name
      t.string :type
      t.references :program, index: true

    end
    add_foreign_key :chef_resources, :programs
  end
end
