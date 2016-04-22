class CreateChefFiles < ActiveRecord::Migration
  def change
    create_table :chef_files do |t|
      t.belongs_to :chef_resource, index: true
      t.belongs_to :personal_chef_resource, index: true
      t.text :content
      t.timestamps null: false
    end
  end
end
