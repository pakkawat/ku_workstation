class CreateProgramChefs < ActiveRecord::Migration
  def change
    create_table :program_chefs do |t|

      t.timestamps null: false
    end
  end
end
