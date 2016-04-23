class PersonalChefResource < ActiveRecord::Base
  has_many :personal_program_chefs, dependent: :destroy
  has_many :personal_programs, through: :personal_program_chefs
  has_many :chef_properties, dependent: :destroy
  has_one :chef_file, dependent: :destroy
  accepts_nested_attributes_for :chef_properties
  default_scope { order("priority ASC") }
end
