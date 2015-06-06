class AddEnabledToProgramsSubjectAndUserSubjects < ActiveRecord::Migration
  def change
    add_column :programs_subjects, :program_enabled, :boolean, default: true
    add_column :user_subjects, :user_enabled, :boolean, default: true
  end
end
