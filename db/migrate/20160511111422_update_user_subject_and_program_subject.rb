class UpdateUserSubjectAndProgramSubject < ActiveRecord::Migration
  def change
    remove_column :user_subjects, :was_updated, :boolean
    remove_column :user_subjects, :status, :string
    rename_column :user_subjects, :installed, :applied

    remove_column :programs_subjects, :status, :string
    rename_column :programs_subjects, :installed, :applied
  end
end
