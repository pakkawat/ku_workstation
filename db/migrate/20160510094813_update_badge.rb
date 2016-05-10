class UpdateBadge < ActiveRecord::Migration
  def change
    add_column :programs_subjects, :status, :string
    add_column :user_subjects, :status, :string
    rename_column :user_subjects, :was_updated, :installed
    rename_column :user_personal_programs, :was_updated, :installed
    rename_column :programs_subjects, :was_updated, :installed
  end
end
