class CreateChefValues < ActiveRecord::Migration
  def change
    create_table :chef_values do |t|
      t.belongs_to :chef_attribute, index: true
      t.belongs_to :ku_user, index: true
      t.string :value

      #t.timestamps null: false
    end
  end
end
