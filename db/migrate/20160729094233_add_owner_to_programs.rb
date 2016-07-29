class AddOwnerToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :owner, :integer
  end
end
