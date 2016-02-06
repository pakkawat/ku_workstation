class Program < ActiveRecord::Base
	has_many :program_files, dependent: :destroy
	has_many :programs_subjects, dependent: :destroy
	has_many :subjects, through: :programs_subjects
	has_many :remove_files, dependent: :destroy
	has_many :users_programs, dependent: :destroy
end
