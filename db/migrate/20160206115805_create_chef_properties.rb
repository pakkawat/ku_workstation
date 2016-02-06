class CreateChefProperties < ActiveRecord::Migration
  def change
    create_table :chef_properties do |t|
      t.string :value

      t.timestamps null: false
    end
  end
end
