class UpdateUserErrors < ActiveRecord::Migration
  def change
    remove_reference :user_errors, :chef_resource   
    remove_reference :user_errors, :personal_chef_resource  
  end
end
