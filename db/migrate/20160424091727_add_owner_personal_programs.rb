class AddOwnerPersonalPrograms < ActiveRecord::Migration
  def change
    add_column :personal_programs, :owner, :integer
  end
end
