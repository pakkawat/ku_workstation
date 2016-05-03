class AddWasUpdated < ActiveRecord::Migration
  def change
    add_column :user_personal_programs, :was_updated, :boolean, default: true
    add_column :user_subjects, :was_updated, :boolean, default: true
    add_column :programs_subjects, :was_updated, :boolean, default: true
  end
end
