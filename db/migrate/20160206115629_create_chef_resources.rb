class CreateChefResources < ActiveRecord::Migration
  def change
    create_table :chef_resources do |t|
      t.string :resource_type

      t.timestamps null: false
    end
  end
end
