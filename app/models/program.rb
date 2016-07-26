class Program < ActiveRecord::Base
	has_many :program_files, dependent: :destroy
	has_many :programs_subjects, dependent: :destroy
	has_many :subjects, through: :programs_subjects
	has_many :remove_resources, dependent: :destroy
	has_many :users_programs, dependent: :destroy
	has_many :program_chefs, dependent: :destroy
	has_many :chef_resources, through: :program_chefs
	validates :program_name, format: { without: /\s/, message: "can't contain spaces" },
	                         uniqueness: { case_sensitive: false }
end
