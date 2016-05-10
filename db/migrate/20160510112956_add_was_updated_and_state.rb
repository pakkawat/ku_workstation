class AddWasUpdatedAndState < ActiveRecord::Migration
  def change
    add_column :user_personal_programs, :was_updated, :boolean
    add_column :user_subjects, :was_updated, :boolean
    add_column :programs_subjects, :was_updated, :boolean

    add_column :user_personal_programs, :state, :string
    add_column :user_subjects, :state, :string
    add_column :programs_subjects, :state, :string
  end
end
