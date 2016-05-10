class ChangeDefaultInstalledColumn < ActiveRecord::Migration
  def up
    change_column_default :programs_subjects, :installed, false
    change_column_default :user_personal_programs, :installed, false
    change_column_default :user_subjects, :installed, false
  end

  def down
    change_column_default :programs_subjects, :installed, false
    change_column_default :user_personal_programs, :installed, false
    change_column_default :user_subjects, :installed, false
  end
end
