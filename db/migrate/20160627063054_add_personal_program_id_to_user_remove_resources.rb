class AddPersonalProgramIdToUserRemoveResources < ActiveRecord::Migration
  def change
    add_column :user_remove_resources, :personal_program_id, :integer
  end
end
