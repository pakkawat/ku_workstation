class PersonalProgram < ActiveRecord::Base
  has_many :user_personal_programs, dependent: :destroy
  has_many :ku_users, through: :user_personal_programs
  has_many :personal_program_chefs, dependent: :destroy
  has_many :personal_chef_resources, through: :personal_program_chefs
  validates :program_name, format: { without: /\s/, message: "can't contain spaces" },
	                         uniqueness: { case_sensitive: false }
end
