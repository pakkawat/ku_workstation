class CreateProgramsSubjects < ActiveRecord::Migration
  def change
    create_table :programs_subjects do |t|
      t.belongs_to :program, index: true
      t.belongs_to :subject, index: true
    end
  end
end
