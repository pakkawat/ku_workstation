class PersonalChefResource < ActiveRecord::Base
  has_many :personal_program_chefs, dependent: :destroy
  has_many :personal_programs, through: :personal_program_chefs
end
