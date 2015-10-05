class CreateRemoveFiles < ActiveRecord::Migration
  def change
    create_table :remove_files do |t|
      t.belongs_to :program, index: true
      t.integer :chef_attribute_id
      t.string :source
    end
    add_foreign_key :remove_files, :programs
  end
end
